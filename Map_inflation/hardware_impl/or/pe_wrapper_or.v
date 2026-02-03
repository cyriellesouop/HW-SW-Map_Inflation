`timescale 1ns/1ps
module pe_wrapper #(
    parameter KERNEL_SIZE  = 3,
    parameter DATA_WIDTH   = 8,
    parameter WEIGHT_WIDTH = 8
)(
    input  clk,
    input  rstn,
    input  en,
    input  [DATA_WIDTH * KERNEL_SIZE - 1 : 0] dataIn,
    input  [(WEIGHT_WIDTH * KERNEL_SIZE * KERNEL_SIZE) - 1 : 0] weightsIn,
    output [(DATA_WIDTH + WEIGHT_WIDTH + KERNEL_SIZE) * KERNEL_SIZE - 1 : 0] dataOut,
    output dataOut_done,
    output ready
);
    localparam PRODUCT_WIDTH = DATA_WIDTH + WEIGHT_WIDTH;
    localparam SUM_WIDTH     = DATA_WIDTH + WEIGHT_WIDTH + KERNEL_SIZE;
    localparam ROW_STRIDE    = DATA_WIDTH * KERNEL_SIZE;
    localparam TOTAL_DONE_DELAY = 3; // Adder + pe latency: 3 cycles
    
    // Bus for vertical pixel propagation
    wire [ROW_STRIDE * (KERNEL_SIZE + 1) - 1 : 0] vertical_pixel_bus;
    wire [KERNEL_SIZE - 1 : 0] row_ready_signals;
    
    assign ready = rstn;
    
    // 1. Input Mapping (Direct wire to start the pipeline)
    assign vertical_pixel_bus[ROW_STRIDE - 1 : 0] = dataIn;
    
    genvar r, c;
    generate
        for (r = 0; r < KERNEL_SIZE; r = r + 1) begin 
            wire [KERNEL_SIZE-1:0] row_pe_dones;
            wire [PRODUCT_WIDTH*KERNEL_SIZE-1:0] products;
            
            // This row's adder is active when its PEs are done
            wire row_adder_en = &row_pe_dones;
            assign row_ready_signals[r] = row_adder_en;
            
            for (c = 0; c < KERNEL_SIZE; c = c + 1) begin 
                pe #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .WEIGHT_WIDTH(WEIGHT_WIDTH)
                ) pe_inst (
                    .clk(clk),
                    .rstn(rstn),
                    .pe_en(en),
                    // Input comes from previous row's output bus
                    .pe_input(vertical_pixel_bus[(r * ROW_STRIDE) + (c * DATA_WIDTH) +: DATA_WIDTH]),
                    .pe_weight(weightsIn[(r*KERNEL_SIZE + c)*WEIGHT_WIDTH +: WEIGHT_WIDTH]),
                    // Output goes to next row's input bus
                    .pe_pixel_out(vertical_pixel_bus[((r+1) * ROW_STRIDE) + (c * DATA_WIDTH) +: DATA_WIDTH]),
                    .pe_output(products[c*PRODUCT_WIDTH +: PRODUCT_WIDTH]),
                    .pe_done(row_pe_dones[c])
                );
            end
            
            // 2. Adder Tree - connect to INTERMEDIATE signal
            adder_tree #(
                .KERNEL_SIZE(KERNEL_SIZE),
                .DATA_WIDTH(DATA_WIDTH),
                .WEIGHT_WIDTH(WEIGHT_WIDTH)
            ) row_sum_adder (
                .clk(clk),
                .rstn(rstn),
                .adder_en(row_adder_en),
                .adder_dataIn(products),
                // Connect to intermediate wire, NOT final output
                .adder_dataOut(dataOut[r*SUM_WIDTH +: SUM_WIDTH])
            );
        end
    endgenerate
    
    // 3. Streaming Done Signal
    delay #(.LATENCY(TOTAL_DONE_DELAY), .WIDTH(1)) delay_inst (
        .clk(clk),
        .rstn(rstn),
        .dataIn(row_ready_signals[0]), // Now we simply look at the enable signal of the first adder row. 
        .dataOut(dataOut_done)
    );
    
    
endmodule
