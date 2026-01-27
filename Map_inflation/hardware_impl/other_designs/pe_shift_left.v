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

    reg [(WEIGHT_WIDTH-1):0] i;
    reg [DATA_WIDTH+WEIGHT_WIDTH-1:0] mult_acc;

    always @(posedge clk) begin
        if (!rstn) begin
            pe_output    <= { (DATA_WIDTH+WEIGHT_WIDTH){1'b0} };
            pe_pixel_out <= { DATA_WIDTH{1'b0} };
        end
        else begin
            // forward pixel regardless
            pe_pixel_out <= pe_input;

            if (pe_en) begin
                mult_acc = { (DATA_WIDTH+WEIGHT_WIDTH){1'b0} };

                // shift-and-add multiplication
                for (i = 0; i < WEIGHT_WIDTH; i = i + 1) begin
                    if (pe_weight[i]) begin
                        mult_acc = mult_acc + (pe_input << i);
                    end
                end
                pe_output <= mult_acc;
            end
        end
    end
endmodule
