`timescale 1ns/1ps

module pe 
   #(
        parameter WEIGHT_WIDTH = 8,
	parameter DATA_WIDTH = 8
    )
    (
	input clk,
	input rstn,
         
	input [(DATA_WIDTH-1):0] pe_input,                   // input pixel 
	input [(WEIGHT_WIDTH-1):0] pe_weight,                // processing element weight
        input pe_en,                                         // when this is asserted,  the PE start
	
	output reg [(DATA_WIDTH-1):0] pe_pixel_out,          // output pixel = input pixel transfered to the next PE
	output reg [(DATA_WIDTH+WEIGHT_WIDTH)-1 :0] pe_output   // this is the result currently computed
     );



































endmodule
