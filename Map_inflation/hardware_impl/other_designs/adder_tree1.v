`timescale 1ns/1ps

module adder_tree 
#(
    parameter KERNEL_SIZE  = 3,  // Number of products to sum
    parameter DATA_WIDTH   = 8,  // Width of input pixel
    parameter WEIGHT_WIDTH = 8   // Width of kernel weight
)
(
    input clk,
    input rstn,

    //input interface
    input adder_en,
    input [(DATA_WIDTH+WEIGHT_WIDTH)*KERNEL_SIZE-1:0] adder_dataIn, // Concatenated PE outputs: each product is (DATA + WEIGHT) bits
    //output interface
//    output reg  [DATA_WIDTH-1:0] adder_dataOut // Final sum output clamped to avoid "Lethal" Values
    output reg  [(DATA_WIDTH + WEIGHT_WIDTH + KERNEL_SIZE) -1:0] adder_dataOut
);

    localparam PRODUCT_WIDTH = DATA_WIDTH + WEIGHT_WIDTH; 
    localparam PARTIAL_SUM_WIDTH = PRODUCT_WIDTH + $clog2(KERNEL_SIZE); // Internal sum needs bits to handle the sum of KERNEL_SIZE products
    localparam FINAL_OUT_WIDTH    = DATA_WIDTH + WEIGHT_WIDTH + KERNEL_SIZE;

    
    // 1. Unpack Inputs array from a wire that contains a concatenation of all the PEs (Kernel_size PEs) output from one row
    reg [PRODUCT_WIDTH-1:0] unpacked_products [0:KERNEL_SIZE-1];
    reg [PARTIAL_SUM_WIDTH-1:0] full_sum;
    reg [KERNEL_SIZE:0] i,j;
    reg sum_en, output_en;  
 
    always @(posedge clk) begin
        if (!rstn) begin
	    output_en <= 1'b0;
	    adder_dataOut <= {FINAL_OUT_WIDTH{1'b0}};
	    full_sum = {PRODUCT_WIDTH{1'b0}};
            // reset the register array
            for (j = 0; j < KERNEL_SIZE; j = j + 1) begin
                unpacked_products[j] <= {PRODUCT_WIDTH{1'b0}};
            end
        end 
	else begin
		sum_en <= adder_en;
	      // STAGE 1: write the input in a register
		if(adder_en) begin
           	   for (j = 0; j < KERNEL_SIZE; j = j + 1) begin
                       unpacked_products[j] <= adder_dataIn[(j+1)*PRODUCT_WIDTH-1 -: PRODUCT_WIDTH];
                   end
	       end

	        output_en <= sum_en;
	        if(sum_en) begin
		   for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
                       full_sum = full_sum + unpacked_products[i];
                   end
		end

               if(output_en) begin
                 // Zero-extend the computed sum to match the final bit width output required
                   adder_dataOut <= {{(FINAL_OUT_WIDTH-PARTIAL_SUM_WIDTH){1'b0}}, full_sum};
	       end 
       end

     end

endmodule
