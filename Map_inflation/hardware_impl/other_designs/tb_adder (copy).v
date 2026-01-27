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
    localparam PARTIAL_SUM_WIDTH = PRODUCT_WIDTH + $clog2(KERNEL_SIZE); // safe
    localparam FINAL_OUT_WIDTH   = DATA_WIDTH + WEIGHT_WIDTH + KERNEL_SIZE;

    localparam PERIOD    = 4;   // 250 MHz
    localparam NUM_TESTS = (1 << INPUT_WIDTH); // 0 to  2**INPUT_WIDTH-1

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
    reg [INPUT_WIDTH-1:0]       adder_dataIn_mem [0:NUM_TESTS-1];
    reg [FINAL_OUT_WIDTH-1:0]   adder_dataOut_mem[0:NUM_TESTS-1];
    reg [FINAL_OUT_WIDTH-1:0]   expected_mem     [0:NUM_TESTS-1];

    // ----------------------------------------------------
    // CONTROL / BOOKKEEPING
    // ----------------------------------------------------
    reg[INPUT_WIDTH : 0] vec, idx;
    reg [INPUT_WIDTH-1:0] errors;

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

    // ----------------------------------------------------
    // CLOCK
    // ----------------------------------------------------
    always #(PERIOD/2) clk = ~clk;

    // ----------------------------------------------------
    // VERIFICATION FUNCTION
    // ----------------------------------------------------
    function [FINAL_OUT_WIDTH-1:0] verification_adder;
        input [INPUT_WIDTH-1:0] din;
       // reg [KERNEL_SIZE:0] k;
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
        rstn   = 0;
        adder_en = 1'b0;
        adder_dataIn = 0;
	errors = 0;
        // Reset
        repeat (6) @(posedge clk);
        rstn = 1;
        repeat (6) @(posedge clk);
	 adder_en  = 1'b1;
         repeat (2) @(posedge clk);
	
        
        idx = 0;

        // ------------------------------------------------
        // APPLY TEST VECTORS
        // ------------------------------------------------
        for (vec = 0; vec < NUM_TESTS; vec = vec + 1) begin
           // @(posedge clk);
           // adder_en     = 1'b1;

            adder_dataIn = vec[INPUT_WIDTH-1:0];

            // Store input
            adder_dataIn_mem[idx] = adder_dataIn;

            // wait for pipeline to produce output
            repeat (10) @(posedge clk);

            // Store DUT output and expected output
            adder_dataOut_mem[idx] = adder_dataOut;
            expected_mem[idx]      = verification_adder(adder_dataIn_mem[idx]);

            idx = idx + 1;
	   // adder_en = 1'b0;
	  //  @(posedge clk);
        end

      //  adder_en = 1'b0;

        // ------------------------------------------------
        // CHECK RESULTS
        // ------------------------------------------------
        for (idx = 0; idx < NUM_TESTS; idx = idx + 1) begin
            $display("%0t IDX=%0d | din=%0d | got=%0d exp=%0d",$time, idx, adder_dataIn_mem[idx], adder_dataOut_mem[idx],expected_mem[idx]);

            if (adder_dataOut_mem[idx] !== expected_mem[idx]) begin
                $display("MISMATCH @%0d | got=%0d exp=%0d", idx, adder_dataOut_mem[idx], expected_mem[idx]);
                errors = errors + 1;
            end
        end

        // ------------------------------------------------
        // SUMMARY
        // ------------------------------------------------
         if (errors == 0)
   	    $display("%0t ALL TESTS PASSED!", $time);
	else
            $display("%0t TEST FAILED: %0d errors", $time ,  errors);

        #100;
        $finish;
    end

endmodule

