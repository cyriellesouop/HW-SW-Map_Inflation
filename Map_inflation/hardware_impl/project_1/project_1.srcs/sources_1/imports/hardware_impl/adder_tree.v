`timescale 1ns/1ps

module adder_tree 
#(
    parameter KERNEL_SIZE  = 3,  // Number of products to sum
    parameter DATA_WIDTH   = 8,  // Width of input pixel
    parameter WEIGHT_WIDTH = 8   // Width of kernel weight
)
(
    input  wire clk,
    input  wire rstn,

    // Concatenated PE outputs: each product is 16 bits (DATA + WEIGHT)
    input  wire [(DATA_WIDTH+WEIGHT_WIDTH)*KERNEL_SIZE-1:0] adder_dataIn,

    // Final sum output clamped to avoid "Lethal" values (max 253)
    output reg  [DATA_WIDTH-1:0] adder_dataOut
);

    // ----------------------------
    // Local Parameters
    // ----------------------------
    localparam PRODUCT_WIDTH = DATA_WIDTH + WEIGHT_WIDTH; // 16 bits
    localparam OUTPUT_WIDTH  = DATA_WIDTH;                // 8 bits
    
    // Internal sum needs bits to handle the sum of KERNEL_SIZE products
    // For KERNEL_SIZE=3, we need 16 + 2 = 18 bits
    localparam INTERNAL_SUM_WIDTH = PRODUCT_WIDTH + $clog2(KERNEL_SIZE);

    // Fixed-point Gain: 0.98 represented as 251/256
    localparam GAIN_FACTOR = 8'd251; 

    // ----------------------------
    // Unpack Inputs
    // ----------------------------
    wire [PRODUCT_WIDTH-1:0] term [0:KERNEL_SIZE-1];

    genvar i;
    generate
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin : UNPACK_INPUTS
            assign term[i] = adder_dataIn[(i+1)*PRODUCT_WIDTH-1 -: PRODUCT_WIDTH];
        end
    endgenerate

    // ----------------------------
    // Adder Tree Logic
    // ----------------------------
    localparam MAX_LEVELS = $clog2(KERNEL_SIZE) + 1;
    // Storage for partial sums with full precision
    wire [INTERNAL_SUM_WIDTH-1:0] level [0:MAX_LEVELS][0:KERNEL_SIZE-1];

    // Level 0: Zero-extend products to internal sum width
    generate
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin : EXTEND_LEVEL0
            assign level[0][i] = {{(INTERNAL_SUM_WIDTH-PRODUCT_WIDTH){1'b0}}, term[i]};
        end
    endgenerate

    // Build the combinational tree
    genvar l, j;
    generate
        for (l = 0; l < MAX_LEVELS; l = l + 1) begin : TREE_LEVELS
            // Calculate how many nodes are in this specific level
            localparam LEVEL_SIZE = (KERNEL_SIZE + (1 << l) - 1) >> l; 
            
            for (j = 0; j < (LEVEL_SIZE + 1) / 2; j = j + 1) begin : NODES
                if ((2*j + 1) < LEVEL_SIZE) begin
                    assign level[l+1][j] = level[l][2*j] + level[l][2*j+1];
                end else if ((2*j) < LEVEL_SIZE) begin
                    assign level[l+1][j] = level[l][2*j];
                end
            end
        end
    endgenerate

    // ----------------------------
    // Gain Application & Saturated Clamping
    // ----------------------------
    wire [INTERNAL_SUM_WIDTH-1:0] raw_sum = level[MAX_LEVELS][0];
    
    // Perform multiplication by gain (18-bit sum * 8-bit gain = 26-bit result)
    wire [INTERNAL_SUM_WIDTH+7:0] scaled_product = raw_sum * GAIN_FACTOR;
    
    // Divide by 256 (shift right by 8) to get the 8-bit equivalent
    // We take the bits corresponding to the 8-bit result after scaling
    wire [7:0] scaled_val = scaled_product[PRODUCT_WIDTH-1:8]; 

    // ----------------------------
    // Register Final Output with Clamping
    // ----------------------------
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            adder_dataOut <= {OUTPUT_WIDTH{1'b0}};
        end else begin
            // CLAMPING LOGIC: 
            // Ensures the inflation never reaches "Lethal" status (254 or 255)
            if (scaled_val >= 8'd254)
                adder_dataOut <= 8'd253; 
            else
                adder_dataOut <= scaled_val;
        end
    end

endmodule