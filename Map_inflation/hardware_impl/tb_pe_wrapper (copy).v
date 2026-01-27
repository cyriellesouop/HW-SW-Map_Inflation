`timescale 1ns/1ps

module tb_pe_wrapper;

    // Parameters
    parameter KERNEL_SIZE  = 3;
    parameter DATA_WIDTH   = 8;
    parameter WEIGHT_WIDTH = 8;
    
    localparam PRODUCT_WIDTH = DATA_WIDTH + WEIGHT_WIDTH;
    localparam SUM_WIDTH  = PRODUCT_WIDTH + KERNEL_SIZE; 
    localparam PERIOD     = 4;
    localparam NUM_TESTS  = 5;
    localparam TOTAL_WEIGHTS = KERNEL_SIZE * KERNEL_SIZE;
    localparam VERTICAL_SKEW = 2;  // number of clock cycles it takes for data to propagate from one row to the next row in your PE array
    localparam ADDITIONAL_DELAY = 1; // Additional pipeline delay observed

    // Signals
    reg clk = 0;
    reg rstn;
    reg en;
    
    // Inputs
    reg [DATA_WIDTH * KERNEL_SIZE - 1 : 0] dataIn;
    reg [(WEIGHT_WIDTH * TOTAL_WEIGHTS) - 1 : 0] weightsIn;
    
    // Outputs
    wire [(SUM_WIDTH * KERNEL_SIZE) - 1 : 0] dataOut;
    wire dataOut_done;

    // Memory arrays
    reg [WEIGHT_WIDTH-1:0] weights_mem [0:TOTAL_WEIGHTS-1];
    reg [DATA_WIDTH * KERNEL_SIZE - 1 : 0] dataIn_mem [0:NUM_TESTS-1];
    reg [SUM_WIDTH - 1 : 0] exp_mem [0:(NUM_TESTS * KERNEL_SIZE) - 1];
    
    // Capture and verification
    reg [(SUM_WIDTH * KERNEL_SIZE) - 1 : 0] results_captured [0:NUM_TESTS + KERNEL_SIZE];
    integer cap_ptr = 0, errors = 0, cycle, test_id;
    integer i, r, c;
    
    // Declare verification variables at module level
    reg [(SUM_WIDTH * KERNEL_SIZE) - 1 : 0] expected_bus;
    reg [(SUM_WIDTH * KERNEL_SIZE) - 1 : 0] actual_bus;
    reg [SUM_WIDTH-1:0] exp_val, act_val;

    // Verification Function: Computes mathematical result for one row
    function [SUM_WIDTH-1:0] verify_row_sum;
        input integer row_idx;
        input [DATA_WIDTH * KERNEL_SIZE - 1 : 0] row_pixels;
        
        reg [SUM_WIDTH-1:0] sum;
        integer k;
        reg [DATA_WIDTH-1:0] current_pixel;
        
        begin
            sum = 0;
            for (k = 0; k < KERNEL_SIZE; k = k + 1) begin
                current_pixel = row_pixels[k*DATA_WIDTH +: DATA_WIDTH];
                sum = sum + (current_pixel * weights_mem[row_idx * KERNEL_SIZE + k]);
            end
            verify_row_sum = sum;
        end
    endfunction

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
        .dataOut_done(dataOut_done)
    );

    // Clock Generation
    always #(PERIOD/2) clk = ~clk;

    // Continuous Capture Logic - capture on rising edge of done signal
    reg dataOut_done_prev;
    
    always @(posedge clk) begin
        if (!rstn) begin
            dataOut_done_prev <= 1'b0;
        end else begin
            dataOut_done_prev <= dataOut_done;
            
            // Capture whenever done is high (the way your design works)
            if (rstn && dataOut_done) begin
                results_captured[cap_ptr] <= dataOut;
                $display("[CAPTURE] Cycle %0d: Captured dataOut = %h", cap_ptr, dataOut);
                cap_ptr <= cap_ptr + 1;
            end
        end
    end

    // Main Test Sequence
    initial begin
        $display("\n========================================");
        $display("  PE Wrapper Testbench - Wavefront Test");
        $display("========================================\n");
        
        // Initialize
        rstn = 0;
        en   = 0;
        dataIn = 0;
        
        // 1. Define Fixed Weights (all weights = row + 1)
        $display("--- Initializing Weights ---");
        for (r = 0; r < KERNEL_SIZE; r = r + 1) begin
            for (c = 0; c < KERNEL_SIZE; c = c + 1) begin
                weights_mem[r * KERNEL_SIZE + c] = r + 1;
                weightsIn[(r * KERNEL_SIZE + c) * WEIGHT_WIDTH +: WEIGHT_WIDTH] = r + 1;
            end
            $display("Row %0d weights: [%0d %0d %0d]", r, r+1, r+1, r+1);
        end

        // Reset sequence
        repeat(5) @(posedge clk);
        rstn = 1;
        repeat(5) @(posedge clk); 
        en = 1;

        // 2. Feed Input Data and Pre-compute Expected Results
        $display("\n--- Injecting Test Data ---");
        for (i = 0; i < NUM_TESTS; i = i + 1) begin
            // Create input: [i, i+1, i+2]
            for (c = 0; c < KERNEL_SIZE; c = c + 1) begin
                dataIn[c*DATA_WIDTH +: DATA_WIDTH] = i + c;
            end
            
            $display("%0t Test %0d: dataIn = [%0d %0d %0d]",$time, i, i, i+1, i+2); 
            
            @(posedge clk);
            dataIn_mem[i] = dataIn;
            
            // Pre-compute expected results for all rows for a given dataIn (x,y,z)
            for (r = 0; r < KERNEL_SIZE; r = r + 1) begin
                exp_mem[i * KERNEL_SIZE + r] = verify_row_sum(r, dataIn_mem[i]); // we store it in the expected emory
                $display("  Row %0d expected sum: %0d", r, exp_mem[i * KERNEL_SIZE + r]);  
            end
        end

        // 3. Flush pipeline
        //waiting for all data that's already in the pipeline to flow through and produce outputs
        // it allow the last input to reach tha last row.
        $display("\n--- Flushing Pipeline ---");
         //wait for a pipeline depth clock cyle: number of cycle for PE to delivers output = 2 + 
         //(number of cycle for data to traverrse one row to the next row)*number of row - 1 = KERNEL_SIZE * VERTICAL_SKEW +
         // adder latency : number of cycle for adder to output the result = 2 +
         // safe margin of 1 cycle.
        repeat(KERNEL_SIZE * VERTICAL_SKEW + 5) @(posedge clk);
        en = 0;
        
        // Wait for all captures
        wait(cap_ptr >= NUM_TESTS+ (KERNEL_SIZE - 1));  // number of cycle we need for ALL rows to see ALL tests
        repeat(5) @(posedge clk);

        // 4. Verification with Temporal Alignment
        $display("\n========================================");
        $display("  Cycle-by-Cycle Verification");
        $display("========================================\n");
        
        // Only check cycles that should have valid data
        // Last valid data appears at cycle: (NUM_TESTS - 1) + (VERTICAL_SKEW * (KERNEL_SIZE - 1)) + ADDITIONAL_DELAY
        for (cycle = 0; cycle < cap_ptr && cycle < NUM_TESTS + KERNEL_SIZE; cycle = cycle + 1) begin
            expected_bus = {(SUM_WIDTH * KERNEL_SIZE){1'bx}};  // Default to X for unfilled rows
            actual_bus = results_captured[cycle];
            
            $display("%0t Cycle %0d:", $time, cycle);
            
            // Reconstruct expected bus based on vertical skew : expected final dataOut value
            for (r = 0; r < KERNEL_SIZE; r = r + 1) begin
                // cycle = current capture cycle
                // VERTICAL_SKEW * r = How much later row r outputs compared to row 0
                //ADDITIONAL_DELAY : initial pipeline delay 
                // Row r appears (VERTICAL_SKEW * r + ADDITIONAL_DELAY) cycles after being fed
                //example, r=0, cycle =1 ==> test_id = 0: "At capture cycle 1, Row 0 is showing Test 0's result"
                 //example, r=1, cycle =3 ==> test_id = 0:  "At capture cycle 3, Row 1 is showing Test 0's result"
                test_id = cycle - (VERTICAL_SKEW * r) - ADDITIONAL_DELAY; // test_id represents the input test that is currently processing at capture cycle for the row r.
                
                if (test_id >= 0 && test_id < NUM_TESTS) begin  // test_id >= 0: Row has received data (not still filling) and test_id < NUM_TESTS: Data is from a valid test
                    exp_val = exp_mem[test_id * KERNEL_SIZE + r];  // Fetch Expected Value from Memory and put it inside exp_val
                    expected_bus[r * SUM_WIDTH +: SUM_WIDTH] = exp_val; //Insert into Expected Bus . The Starting bit position for Row r's output is r * SUM_WIDTH
                    $display("  Row %0d: Test %0d result = %0d (0x%h)", r, test_id, exp_val, exp_val);
                end else begin
                    expected_bus[r * SUM_WIDTH +: SUM_WIDTH] = 0;
                    $display("  Row %0d: [pipeline filling/flushing] = X", r);
                end
            end
            
            // Compare
            if (actual_bus === expected_bus) begin
                $display("MATCH: %h\n", actual_bus);
            end else begin
                $display("MISMATCH: Expected: %h, Actual %h \n", expected_bus,actual_bus );

                
                // Per-row comparison for debugging
                for (r = 0; r < KERNEL_SIZE; r = r + 1) begin
                    exp_val = expected_bus[r * SUM_WIDTH +: SUM_WIDTH];
                    act_val = actual_bus[r * SUM_WIDTH +: SUM_WIDTH];
                    if (exp_val !== act_val) begin
                        $display("Row %0d: Expected %0d (0x%h), Got %0d (0x%h)", r, exp_val, exp_val, act_val, act_val);
                    end
                end
                errors = errors + 1;
            end
        end

        // Final Summary
        $display("\n========================================");
        if (errors == 0) begin
            $display("SUCCESS: All %0d tests passed!", NUM_TESTS);
        end else begin
            $display("FAILURE: %0d mismatches found", errors);
        end

        #200;
        $finish;
    end

endmodule
