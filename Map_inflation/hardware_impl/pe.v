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
	output reg [(DATA_WIDTH+WEIGHT_WIDTH)-1 :0] pe_output,  // this is the result currently computed
	output reg pe_done
     );

    // Input Registers
    reg [(DATA_WIDTH-1):0] pe_input_reg;
    reg [(WEIGHT_WIDTH-1):0] pe_weight_reg;

    reg  pe_en_reg;

    always @(posedge clk) begin
        if (!rstn) begin
	    pe_input_reg  <= 0;
            pe_weight_reg <= 0;
            pe_output     <= 0;
            pe_pixel_out  <= 0;
            pe_done    <= 1'b0;
	    pe_en_reg <= 0;
        end
        else begin
	    // register  inputs
	    pe_input_reg <= pe_input;
	    pe_weight_reg <= pe_weight;

            
            pe_en_reg <= pe_en;
            // forward pixel regardless
           // pe_pixel_out <= pe_input_reg;
           // pe_pixel_out <= pe_input;
            if (pe_en_reg) begin
                pe_pixel_out <= pe_input_reg; // to allow differents row pe to get an input at the same clock cyle
                
		(* use_dsp = "yes" *) // to Map the multiplication below to a DSP block
                pe_output <= pe_input_reg * pe_weight_reg;
                pe_done    <= 1'b1;
            end
            else
                begin
            	   pe_done    <= 1'b0;
            	 //  pe_output <= 0;
            	 //  pe_pixel_out <= 0;
            	end
            	
               
       end
   end
endmodule
