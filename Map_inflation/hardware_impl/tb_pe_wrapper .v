`timescale 1ns/1ps

module tb_pe_wrapper;

    // --- Parameters ---
    parameter KERNEL_SIZE  = 3;
    parameter DATA_WIDTH   = 8;
    parameter WEIGHT_WIDTH = 8;
    
    // Exact bit-width calculation for 19-bit stride
    localparam SUM_WIDTH = DATA_WIDTH + WEIGHT_WIDTH + $clog2(KERNEL_SIZE); 
    localparam PERIOD    = 10;
    localparam NUM_TESTS = 20; // Increased for robustness

    // --- Signals ---
    reg clk = 0;
    reg rstn;
    reg en;
    reg [DATA_WIDTH * KERNEL_SIZE - 1 : 0] dataIn;
    reg [(WEIGHT_WIDTH * KERNEL_SIZE * KERNEL_SIZE) - 1 : 0] weightsIn;
    
    wire [(SUM_WIDTH * KERNEL_SIZE) - 1 : 0] dataOut;
    wire dataOut_done;
    wire ready;

    // --- Golden Model Storage ---
    // Queues to store expected results for each row
    reg [SUM_WIDTH-1:0] row0_queue [0:NUM_TESTS-1];
    reg [SUM_WIDTH-1:0] row1_queue [0:NUM_TESTS-1];
    reg [SUM_WIDTH-1:0] row2_queue [0:NUM_TESTS-1];

    // --- DUT ---
     // DUT Instance
    pe_wrapper #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .WEIGHT_WIDTH(WEIGHT_WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .en(en),
        .dataIn(dataIn),
        .weightsIn(weightsIn),
        .dataOut(dataOut),
        .dataOut_done(dataOut_done),
	.ready(ready)
    );


    always #(PERIOD/2) clk = ~clk;

    // --- Testbench Variables ---
    integer i, r, c, errors = 0;
    reg [WEIGHT_WIDTH-1:0] test_weights [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1];

    // --- Task: Initialize Weights ---
    task set_weights(input integer seed);
        begin
            for (r = 0; r < KERNEL_SIZE; r = r + 1) begin
                for (c = 0; c < KERNEL_SIZE; c = c + 1) begin
                    test_weights[r][c] = (r + c + seed); // Semi-random patterns
                    weightsIn[(r*KERNEL_SIZE + c)*WEIGHT_WIDTH +: WEIGHT_WIDTH] = test_weights[r][c];
                end
            end
        end
    endtask

    // --- Task: Generate Golden Data ---
    // Pre-calculates what the systolic array SHOULD output
    task calc_golden();
        reg [DATA_WIDTH-1:0] current_input [0:KERNEL_SIZE-1];
        reg [SUM_WIDTH-1:0] sum;
        begin
            for (i = 0; i < NUM_TESTS; i = i + 1) begin
                // Simulate input [i, i+1, i+2]
                for (c = 0; c < KERNEL_SIZE; c = c + 1) current_input[c] = i + c;
                
                // Calculate expected sum for each row independently
                for (r = 0; r < KERNEL_SIZE; r = r + 1) begin
                    sum = 0;
                    for (c = 0; c < KERNEL_SIZE; c = c + 1) begin
                        sum = sum + (current_input[c] * test_weights[r][c]);
                    end
                    // Store in queues
                    if (r == 0) row0_queue[i] = sum;
                    if (r == 1) row1_queue[i] = sum;
                    if (r == 2) row2_queue[i] = sum;
                end
            end
        end
    endtask

    // --- Main Simulation Control ---
    initial begin
        rstn = 0; en = 0; dataIn = 0;
        set_weights(1); // Configuration 1
        calc_golden();
        
        #100 rstn = 1;
        wait(ready);
        @(posedge clk); en = 1;

        // Feed Data
        for (i = 0; i < NUM_TESTS; i = i + 1) begin
            for (c = 0; c < KERNEL_SIZE; c = c + 1) begin
                dataIn[c*DATA_WIDTH +: DATA_WIDTH] = i + c;
            end
            @(posedge clk);
        end
        en = 0;

        #200;
        if (errors == 0) $display("**** TEST PASSED: All %0d results match! ****", NUM_TESTS * 3);
        else            $display("**** TEST FAILED: %0d mismatches found ****", errors);
        $finish;
    end

    // --- AUTOMATIC CHECKER LOGIC ---
    // Row 0 Checker
    integer r0_ptr = 0;
    always @(posedge clk) begin
        // Row 0 is valid after Latency 3
        if (rstn && dataOut_done && r0_ptr < NUM_TESTS) begin
            check_result(0, dataOut[0*SUM_WIDTH +: SUM_WIDTH], row0_queue[r0_ptr], r0_ptr);
            r0_ptr <= r0_ptr + 1;
        end
    end

    // Row 1 Checker (1 cycle after Row 0)
    integer r1_ptr = 0;
    always @(posedge clk) begin
        if (rstn && dataOut_done && r0_ptr > 1 && r1_ptr < NUM_TESTS) begin
            check_result(1, dataOut[1*SUM_WIDTH +: SUM_WIDTH], row1_queue[r1_ptr], r1_ptr);
            r1_ptr <= r1_ptr + 1;
        end
    end

    // Row 2 Checker (2 cycles after Row 0)
    integer r2_ptr = 0;
    always @(posedge clk) begin
        if (rstn && dataOut_done && r0_ptr > 2 && r2_ptr < NUM_TESTS) begin
            check_result(2, dataOut[2*SUM_WIDTH +: SUM_WIDTH], row2_queue[r2_ptr], r2_ptr);
            r2_ptr <= r2_ptr + 1;
        end
    end

    // --- Helper Task: Comparison ---
    task check_result(input integer row, input [SUM_WIDTH-1:0] act, input [SUM_WIDTH-1:0] exp, input integer idx);
        begin
            if (act !== exp) begin
                $display("[ERROR] T=%0t Row %0d Test %0d | Expected: %h, Got: %h", $time, row, idx, exp, act);
                errors = errors + 1;
            end else begin
                $display("[PASS] Row %0d Test %0d: %h", row, idx, act);
            end
        end
    endtask

endmodule
