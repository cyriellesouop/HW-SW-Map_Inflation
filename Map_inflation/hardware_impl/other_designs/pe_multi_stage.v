`timescale 1ns/1ps

module pe 
   #(
        parameter WEIGHT_WIDTH = 8,
	parameter DATA_WIDTH = 8
    )
    (
	input clk,
	input rstn,
        //inputs interface	
	input [(DATA_WIDTH-1):0] pe_input,                   // input pixel 
	input [(WEIGHT_WIDTH-1):0] pe_weight,                // processing element weight
        input pe_en,                                         // when this is asserted,  the PE start
	// outpute interface
	output reg [(DATA_WIDTH-1):0] pe_pixel_out,          // output pixel = input pixel transfered to the next PE
	output reg [(DATA_WIDTH+WEIGHT_WIDTH)-1 :0] pe_output   // this is the result currently computed
     );

    reg [(WEIGHT_WIDTH-1):0] i;  // use for loop indexing

    // Pipeline Registers
    reg [(DATA_WIDTH-1):0] pe_input_reg;
    reg [(WEIGHT_WIDTH-1):0] pe_weight_reg;
    reg [DATA_WIDTH+WEIGHT_WIDTH-1:0] sum_reg;
    reg [DATA_WIDTH+WEIGHT_WIDTH-1:0] partial_mult [0:WEIGHT_WIDTH-1];

    reg  pe_en_partial_mult;
    reg  pe_en_sum;

    always @(posedge clk) begin
        if (!rstn) begin
	    for (i = 0; i < WEIGHT_WIDTH; i = i + 1) begin
                partial_mult[i] <= 0;
            end
	    pe_input_reg  <= 0;
            pe_weight_reg <= 0;
            pe_output     <= 0;
            pe_pixel_out  <= 0;
	    pe_en_partial_mult <= 0;
	    pe_en_sum <= 0;
        end
        else begin
	    // register  inputs
	    pe_input_reg <= pe_input;
	    pe_weight_reg <= pe_weight;

            // forward pixel regardless
            pe_pixel_out <= pe_input_reg;

	    // Stage 1 :compute partial multiplication with shift left operator
	    pe_en_partial_mult <= pe_en;
            if (pe_en) begin
                // shift multiplication
                for (i = 0; i < WEIGHT_WIDTH; i = i + 1) begin
                    if (pe_weight_reg[i]) 
			  partial_mult[i] <= (pe_input_reg << i);
		    else
			  partial_mult[i] <= 0;
                end
            end

	    // Stage 2 : Final accumulation of partial multiplcation
	    pe_en_sum <= pe_en_partial_mult;
	    if (pe_en_partial_mult) begin
		sum_reg = 0;
		for (i = 0; i < WEIGHT_WIDTH; i = i + 1) begin
                    sum_reg = sum_reg + partial_mult[i];
                end
		pe_output <= sum_reg;
	    end
	  /*
	    if (pe_en_sum) begin
	        pe_output <= sum_reg;
            end
	 */
       end
   end
endmodule
