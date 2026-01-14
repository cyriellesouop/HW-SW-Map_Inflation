`timescale 1ns/1ps

module tb_pe;

    parameter DATA_WIDTH = 8;
    parameter WEIGHT_WIDTH = 1;
    parameter RESULT_WIDTH = DATA_WIDTH + WEIGHT_WIDTH;
    localparam PERIOD = 4; //250 MHZ

    // DUT Inputs
    reg clk=0;
    reg rstn;
    reg [DATA_WIDTH-1:0] dataIn;
    reg [WEIGHT_WIDTH-1:0] weight;
    reg [RESULT_WIDTH:0] prev_result;
    reg pe_en;

    // DUT Outputs
    wire [DATA_WIDTH-1:0] dataOut;
    wire [RESULT_WIDTH:0] next_result;
    wire pe_done;

    // Instantiate DUT
    pe #(.DATA_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH))
   
     DUT (
        .clk(clk),
        .rstn(rstn),
        .dataIn(dataIn),
        .weight(weight),
        .prev_result(prev_result),
        .pe_en(pe_en),
        .dataOut(dataOut),
        .next_result(next_result),
        .pe_done(pe_done)
    );

    
    always #(PERIOD/2) clk = ~clk;

    // ------------------------------------
    // Verification Function
    // ------------------------------------
    function [RESULT_WIDTH:0] expected_result;
        input [DATA_WIDTH-1:0] dataIn_f;
        input [WEIGHT_WIDTH-1:0] weight_f;
        input [RESULT_WIDTH:0] prev_res_f;
    begin
        expected_result = (dataIn_f * weight_f) + prev_res_f;
    end
    endfunction

    reg[3:0] i,j,k;
    reg [RESULT_WIDTH:0] expected_value; // expected value register
    integer error_count = 0;

    initial begin
        // Initialize
        rstn = 0;
        pe_en = 0;
        dataIn = 0;
        weight = 0;
        prev_result = 0;

        repeat(2)@(posedge clk);
       	rstn = 1;
        @(posedge clk);

        // ------------------------------------
        // Test Loops for many iteration
        // ------------------------------------
        for (i = 0; i < 4'd10; i = i + 1) begin
            for (j = 0; j < 4'd10; j = j + 1) begin
                for (k = 0; k < 4'd3; k = k + 1) begin

                    @(posedge clk);
                    pe_en = 1;
		    @(posedge clk);
                    dataIn = i;
                    prev_result = j;
                    weight = k;
		    @(posedge clk);
                    expected_value = expected_result(i,k,j);

                    repeat(20)@(posedge clk); // wait for the result to appear
                    pe_en = 0;
                    
                    if (pe_done &&(next_result !== expected_value)) begin
			error_count = error_count + 1;
                        $display("%0t ERROR : dataIn=%0d weight=%0d prev=%0d => expected=%0d DUT=%0d", $time ,i, k, j, expected_value, next_result);
                    end
		  /* 
		    else begin
                        $display("%0t PASS: dataIn=%0d weight=%0d prev=%0d => expected=%0d DUT=%0d",$time,  i, k, j,expected_value, next_result);
                    end
		  */
		    pe_en = 0;
                    @(posedge clk);
                end
            end
        end
	if(error_count === 0 )
	    $monitor("%0t ALL THE TEST HAS PASSED !!! ", $time);

        #100;
        $finish;
    end

endmodule

