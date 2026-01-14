`timescale 1ns/1ps

module pe_axis
   #(
        parameter WEIGHT_WIDTH = 1,
        parameter DATA_WIDTH = 8
    )
    (
        input clk,
        input rstn,

        input [(DATA_WIDTH-1):0] dataIn, //input pixel 
        input [(WEIGHT_WIDTH-1):0] weight,
        input [(DATA_WIDTH+WEIGHT_WIDTH):0] prev_result,// this result is the output of the previous pE
        //input pe_en,                  // when this is asserted,  the PE start

        output reg [(DATA_WIDTH-1):0] dataOut, // output pixel = input pixel transfered to the next PE
        output reg [(DATA_WIDTH+WEIGHT_WIDTH):0] next_result, // this is the result currently computed
        output reg pe_done
     );

     reg[(DATA_WIDTH + WEIGHT_WIDTH)-1:0] mult_r;

     always @(posedge clk) begin
         if(~rstn) begin
            dataOut <= 0;
            next_result <= 0;
            pe_done <= 0;
            mult_r <= 0;

         end else begin
            if(pe_en) begin
               mult_r <= dataIn * weight;
               next_result <= mult_r + prev_result;

               dataOut <= dataIn;
               pe_done <= 1;
            end
            else begin
                pe_done <=0; // clear only the done signal contoller 
            end
         end
     end

endmodule

