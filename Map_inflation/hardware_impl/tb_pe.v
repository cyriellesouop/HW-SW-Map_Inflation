`timescale 1ns/1ps

module tb_pe;

    parameter DATA_WIDTH   = 8;
    parameter WEIGHT_WIDTH = 8;
    parameter TOTAL_WIDTH  = DATA_WIDTH + WEIGHT_WIDTH;
    localparam PERIOD = 4; //250 MHZ
    localparam NUM_TESTS = (1 << TOTAL_WIDTH);

    reg clk=0;
    reg rstn;
    reg pe_en;
    reg  [DATA_WIDTH-1:0]   pe_input;
    reg  [WEIGHT_WIDTH-1:0] pe_weight;
    wire [DATA_WIDTH-1:0] pe_pixel_out;
    wire [TOTAL_WIDTH-1:0] pe_output;

    reg [TOTAL_WIDTH:0] vec;
    reg [TOTAL_WIDTH-1:0] errors;

    reg [TOTAL_WIDTH:0] idx; // array index for inputs values
    // Input values store in arrays
    reg [DATA_WIDTH-1:0]   pe_input_mem   [0:NUM_TESTS-1];  // array for the pe_input values
    reg [WEIGHT_WIDTH-1:0] pe_weight_mem  [0:NUM_TESTS-1];  // array for the pe_weight values

   // Output values store in arrays
   reg [DATA_WIDTH-1:0] pe_pixel_out_mem [0:NUM_TESTS-1]; // array for pixel out values.
   reg [TOTAL_WIDTH-1:0] pe_output_mem   [0:NUM_TESTS-1];   // array pe_output computed
   reg [TOTAL_WIDTH-1:0] expected_mem      [0:NUM_TESTS-1];   // array for expected_output computed

    // ----------------------------------------------------
    // DUT
    // ----------------------------------------------------
    pe #(
        .DATA_WIDTH(DATA_WIDTH),
        .WEIGHT_WIDTH(WEIGHT_WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .pe_input(pe_input),
        .pe_weight(pe_weight),
        .pe_en(pe_en),
        .pe_pixel_out(pe_pixel_out),
        .pe_output(pe_output)
    );

    
    // -----------------------------------------
    function [TOTAL_WIDTH-1:0] verification_mult;
        input [DATA_WIDTH-1:0]   a;
        input [WEIGHT_WIDTH-1:0] b;
       
        begin
            verification_mult = a * b;
        end
    endfunction

    // --------------Clock Generation --------------------------------
    always #(PERIOD/2) clk = ~clk;

    // ----------------------------------------------------
    // Test
    // ----------------------------------------------------
    initial begin
        rstn   = 0;
        pe_en  = 0;
        errors = 0;
        pe_input  = 0;
        pe_weight = 0;
	
	repeat(2)@(posedge clk);
        // Reset
        rstn = 1;
	repeat(2)@(posedge clk);
        pe_en = 1;
	@(posedge clk);
	idx = 0;
        // Exhaustive test
        for (vec = 0; vec < NUM_TESTS; vec = vec + 1) begin
            {pe_weight, pe_input} = vec[TOTAL_WIDTH-1:0];
	    
	    // Store inputs
   	    pe_input_mem[idx]  = pe_input;
   	    pe_weight_mem[idx] = pe_weight;

            repeat(5) @(posedge clk); // wait for result
	 
	     pe_output_mem[idx] = pe_output;
    	     expected_mem[idx]  = verification_mult(pe_input, pe_weight);
	     pe_pixel_out_mem[idx] = pe_pixel_out;
             idx = idx + 1;

	end

        for (idx = 0; idx < NUM_TESTS; idx = idx + 1) begin

	    $display( "%0t Values @%0d: input=%0d pixel_out = %0d weight=%0d | got=%0d exp=%0d", $time, idx, pe_input_mem[idx], pe_pixel_out_mem[idx], pe_weight_mem[idx], pe_output_mem[idx], expected_mem[idx] );
   	    if (pe_output_mem[idx] !== expected_mem[idx]) begin
               $display( "%0t MISMATCH @%0d: input=%0d weight=%0d | got=%0d exp=%0d", $time, idx, pe_input_mem[idx], pe_weight_mem[idx], pe_output_mem[idx], expected_mem[idx] );
               errors = errors + 1;
            end
        end


        if (errors == 0)
   	    $display("%0t ALL TESTS PASSED!", $time);
	else
            $display("%0t TEST FAILED: %0d errors", $time ,  errors);
    	
        #100;
        $finish;
    end

endmodule

