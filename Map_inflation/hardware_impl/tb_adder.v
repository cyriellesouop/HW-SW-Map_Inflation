`timescale 1ns/1ps

module tb_adder;

    // ----------------------------------------------------
    // PARAMETERS
    // ----------------------------------------------------
    parameter KERNEL_SIZE  = 3;
    parameter DATA_WIDTH   = 8;
    parameter WEIGHT_WIDTH = 8;

    localparam PRODUCT_WIDTH     = DATA_WIDTH + WEIGHT_WIDTH;
    localparam INPUT_WIDTH       = PRODUCT_WIDTH * KERNEL_SIZE;
    localparam PARTIAL_SUM_WIDTH = PRODUCT_WIDTH + $clog2(KERNEL_SIZE);
    localparam FINAL_OUT_WIDTH   = DATA_WIDTH + WEIGHT_WIDTH + KERNEL_SIZE;

    localparam PERIOD    = 4;   // 250 MHz
    localparam NUM_TESTS = 1000; // Reasonable number of random tests
    localparam PIPELINE_DEPTH = 2; // Your adder has 2 pipeline stages

    // ----------------------------------------------------
    // DUT SIGNALS
    // ----------------------------------------------------
    reg clk = 0;
    reg rstn;
    reg adder_en;
    reg [INPUT_WIDTH-1:0] adder_dataIn;
    wire [FINAL_OUT_WIDTH-1:0] adder_dataOut;

    // ----------------------------------------------------
    // ARRAYS FOR STORAGE
    // ----------------------------------------------------
    reg [INPUT_WIDTH-1:0]       dataIn_mem [0:NUM_TESTS+PIPELINE_DEPTH-1];
    reg [FINAL_OUT_WIDTH-1:0]   dataOut_mem[0:NUM_TESTS-1];
    reg [FINAL_OUT_WIDTH-1:0]   expected_mem[0:NUM_TESTS-1];

    // ----------------------------------------------------
    // CONTROL / BOOKKEEPING
    // ----------------------------------------------------
    integer vec, output_idx, check_idx;
    integer errors;
    reg [INPUT_WIDTH-1:0] random_data;

    // ----------------------------------------------------
    // DUT
    // ----------------------------------------------------
    adder_tree #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .WEIGHT_WIDTH(WEIGHT_WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .adder_en(adder_en),
        .adder_dataIn(adder_dataIn),
        .adder_dataOut(adder_dataOut)
    );

    
    // ---------------clock generation --------------------
    always #(PERIOD/2) clk = ~clk;

    // ----------------------------------------------------
    // VERIFICATION FUNCTION
    // ----------------------------------------------------
    function [FINAL_OUT_WIDTH-1:0] verification_adder;
        input [INPUT_WIDTH-1:0] din;
        integer k;
        reg [PRODUCT_WIDTH-1:0] tmp;
        reg [PARTIAL_SUM_WIDTH-1:0] sum;
        begin
            sum = 0;
            for (k = 0; k < KERNEL_SIZE; k = k + 1) begin
                tmp = din[(k+1)*PRODUCT_WIDTH-1 -: PRODUCT_WIDTH];
                sum = sum + tmp;
            end
            verification_adder = {{(FINAL_OUT_WIDTH-PARTIAL_SUM_WIDTH){1'b0}}, sum};            
        end
    endfunction

    // ----------------------------------------------------
    // TEST
    // ----------------------------------------------------
    initial begin
        // Initialize
        rstn   = 0;
        adder_en = 1'b0;
        adder_dataIn = 0;
        errors = 0;
        output_idx = 0;
       // total_tests = NUM_TESTS;
        random_data = 0;

        repeat (4) @(posedge clk);
        rstn = 1;
        repeat (4) @(posedge clk);
        adder_en = 1'b1;

        // loop into test data
        for (vec = 0; vec < NUM_TESTS; vec = vec + 1) begin
            @(posedge clk);
            
            // Generate test data: mix of random values
            if (vec == 0)
                random_data = {INPUT_WIDTH{1'b0}}; // All zeros
            else if (vec == 1)
                random_data = {INPUT_WIDTH{1'b1}}; // All ones
            else if (vec < 10)
                random_data = (1 << (vec-2)); // vec=2 (ran_data = 1) , vec=3 (ran_data = 2) , vec=4 (ran_data = 4), vec=5 (ran_data = 8), ... , vec=9 (ran_data = 128)
            else
                random_data = {$random, $random}; // 64 bits Random data : only the lower INPUT_WIDTH are kept 
            
            adder_dataIn = random_data;  // we assign the random_data to our input data for testing
            
            // Store input and compute expected output
            dataIn_mem[vec] = adder_dataIn;
            expected_mem[vec] = verification_adder(adder_dataIn);
            
            //  Start capturing the first output after pipeline fills (2 cycles)
            if (vec >= PIPELINE_DEPTH) begin
                dataOut_mem[output_idx] = adder_dataOut;
                output_idx = output_idx + 1;
            end
        end

        // --------------capture remaining outputs------------
        for (vec = 0; vec < PIPELINE_DEPTH; vec = vec + 1) begin
            @(posedge clk);
           dataOut_mem[output_idx] = adder_dataOut;
            output_idx = output_idx + 1;
        end

        adder_en = 1'b0;
        @(posedge clk);

        //---------------- CHECK RESULTS ---------------- 
        for (check_idx = 0; check_idx < NUM_TESTS; check_idx = check_idx + 1) begin
            if (dataOut_mem[check_idx] !== expected_mem[check_idx]) begin
                $display("%0t MISMATCH @%0d | input=%0d | got=%0d exp=%0d", $time, check_idx, dataIn_mem[check_idx], dataOut_mem[check_idx], expected_mem[check_idx]); //display errors
                errors = errors + 1;
            end
        end

        // ------------------------------------------------
        if (errors == 0) 
            $display(" %0t ALL %0d TESTS PASSED!",$time,  NUM_TESTS);
        else 
            $display("%0t TEST FAILED: %0d errors", $time, errors);

        #10000;
        $finish;
    end
endmodule
