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
    output reg  [(DATA_WIDTH + WEIGHT_WIDTH + KERNEL_SIZE) -1:0] adder_dataOut;
);

    localparam PRODUCT_WIDTH = DATA_WIDTH + WEIGHT_WIDTH; 
    localparam PARTIAL_SUM_WIDTH = PRODUCT_WIDTH + $clog2(KERNEL_SIZE); // Internal sum needs bits to handle the sum of KERNEL_SIZE products
    localparam FINAL_OUT_WIDTH    = DATA_WIDTH + WEIGHT_WIDTH + KERNEL_SIZE;
    localparam GAIN_FACTOR = 8'd251;  // scale factor 251/256

    
    // 1. Unpack Inputs array from a wire that contains a concatenation of all the PEs (Kernel_size PEs) output from one row
    reg [PRODUCT_WIDTH-1:0] Unpacked_products [0:KERNEL_SIZE-1];
    reg [PARTIAL_SUM_WIDTH-1:0] full_sum;
    reg [KERNEL_SIZE-1:0] i,j;
    reg output_en, clamping_en;  

   // PIPELINE STAGE 1: write the input in a register
    always @(posedge clk) begin
        if (!rstn) begin
	    output_en <= 1'b0
            // reset the register array
            for (j = 0; j < KERNEL_SIZE; j = j + 1) begin
                unpacked_products[j] <= 0;
            end
        end else begin
		output_en <= adder_en;
		if(adder_en) begin
           	   // write data into registers
           	   for (j = 0; j < KERNEL_SIZE; j = j + 1) begin
                       unpacked_products[j] <= adder_dataIn[(j+1)*PRODUCT_WIDTH-1 -: PRODUCT_WIDTH];
                   end
	       end
        end
    end

    // 2. Perform the addition For small KERNEL_SIZE 
    always @(*) begin
        full_sum = 0;
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
            full_sum = full_sum + unpacked_products[i];
        end
    end

    // 3. Final output
    always @(posedge clk) begin
        if (!rstn) begin
            adder_dataOut <= {FINAL_OUT_WIDTH{1'b0}};
        end else if (output_en) begin
            // Zero-extend the computed sum to match the final bit width output required
            adder_dataOut <= {{(FINAL_OUT_WIDTH-PARTIAL_SUM_WIDTH){1'b0}}, full_sum};
        end
    end

    /*
   // --- PIPELINE STAGE 2: Output Registration & Saturation ---
    always @(posedge clk) begin
        if (!rstn) begin
            adder_dataOut <= 0;
        end else begin
            if(clamping_en)
            // Saturation logic to 8-bit max
           	 if (full_sum > {{(PARTIAL_SUM_WIDTH-DATA_WIDTH){1'b0}}, {DATA_WIDTH{1'b1}}})
               	    adder_dataOut <= {DATA_WIDTH{1'b1}};
            else
                adder_dataOut <= full_sum[DATA_WIDTH-1:0];
        end
    end


    // Register Final Output with Clamping
    always @(posedge clk) begin
        if (!rstn) begin
            adder_dataOut <= {DATA_WIDTH{1'b0}};
        end else begin
            // CLAMPING LOGIC to ensures the inflation never reaches "Lethal" status (254 or 255)
            if (scaled_val >= 8'd254)
                adder_dataOut <= 8'd253; 
            else
                adder_dataOut <= scaled_val;
        end
    end
    */

endmodule
