`timescale 1ns/1ps

module adder_tree #(
    parameter KERNEL_SIZE  = 3,  // Number of products to sum
    parameter DATA_WIDTH   = 8,  // Width of input pixel
    parameter WEIGHT_WIDTH = 8   // Width of kernel weight
)(
    input  wire clk,
    input  wire rstn,

    // Input interface
    input  wire adder_en,
    input  wire [(DATA_WIDTH + WEIGHT_WIDTH) * KERNEL_SIZE - 1 : 0] adder_dataIn,
    // Concatenated PE outputs: each product is (DATA + WEIGHT) bits

    // Output interface
    // output reg [DATA_WIDTH-1:0] adder_dataOut // Optional clamped output
    output reg  [(DATA_WIDTH + WEIGHT_WIDTH + KERNEL_SIZE) - 1 : 0] adder_dataOut
);

    // ------------------------------------------------------------------
    // Local parameters
    // ------------------------------------------------------------------
    localparam PRODUCT_WIDTH     = DATA_WIDTH + WEIGHT_WIDTH;
    localparam PARTIAL_SUM_WIDTH = PRODUCT_WIDTH + $clog2(KERNEL_SIZE);
    localparam FINAL_OUT_WIDTH   = DATA_WIDTH + WEIGHT_WIDTH + KERNEL_SIZE;

    // ------------------------------------------------------------------
    // Internal signals
    // ------------------------------------------------------------------
    reg [PRODUCT_WIDTH-1:0]     unpacked_products [0:KERNEL_SIZE-1];
    reg [PARTIAL_SUM_WIDTH-1:0] full_sum;
    reg [KERNEL_SIZE:0] i,j;
    reg output_en;

    // ------------------------------------------------------------------
    // PIPELINE STAGE 1: Register input products
    // ------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rstn) begin
            output_en <= 1'b0;
            for (j = 0; j < KERNEL_SIZE; j = j + 1) begin
                unpacked_products[j] <= {PRODUCT_WIDTH{1'b0}};
            end
        end
        else begin
            output_en <= adder_en;
            if (adder_en) begin
                for (j = 0; j < KERNEL_SIZE; j = j + 1) begin
                    unpacked_products[j] <=
                        adder_dataIn[(j+1)*PRODUCT_WIDTH-1 -: PRODUCT_WIDTH];
                end
            end
        end
    end

    // ------------------------------------------------------------------
    // STAGE 2: Combinational addition (adder tree)
    // ------------------------------------------------------------------
    always @(*) begin
        full_sum = {PARTIAL_SUM_WIDTH{1'b0}};
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
            full_sum = full_sum + unpacked_products[i];
        end
    end

    // ------------------------------------------------------------------
    // STAGE 3: Output register
    // ------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rstn) begin
            adder_dataOut <= {FINAL_OUT_WIDTH{1'b0}};
        end
        else if (output_en) begin
            adder_dataOut <= {
                {(FINAL_OUT_WIDTH - PARTIAL_SUM_WIDTH){1'b0}},
                full_sum
            };
        end
    end

endmodule

