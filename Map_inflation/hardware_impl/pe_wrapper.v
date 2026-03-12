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

    input m_axis_tready,
    output [(DATA_WIDTH + WEIGHT_WIDTH +  $clog2(KERNEL_SIZE)) - 1 : 0] m_axis_tdata,
    output m_axis_tvalid,
   // output [(DATA_WIDTH + WEIGHT_WIDTH + KERNEL_SIZE) * KERNEL_SIZE - 1 : 0] dataOut,
    output ready
);
    localparam PRODUCT_WIDTH = DATA_WIDTH + WEIGHT_WIDTH;
    localparam SUM_WIDTH     = DATA_WIDTH + WEIGHT_WIDTH + $clog2(KERNEL_SIZE);
    localparam PARTIAL_SUM_WIDTH = PRODUCT_WIDTH + $clog2(KERNEL_SIZE);
    localparam ROW_STRIDE    = DATA_WIDTH * KERNEL_SIZE;
    localparam TOTAL_DONE_DELAY = 3; // Adder latency: 3 cycles
    
    //reg start_counter;
    
    // Bus for vertical pixel propagation
    wire [ROW_STRIDE * (KERNEL_SIZE + 1) - 1 : 0] vertical_pixel_bus;
    wire [KERNEL_SIZE - 1 : 0] row_ready_signals;
    
    // --- Intermediate AXI-Stream signals to collect results from all rows ---
    wire [KERNEL_SIZE-1:0] row_tvalid;
    wire [KERNEL_SIZE-1:0] row_tready;
    wire [PARTIAL_SUM_WIDTH * KERNEL_SIZE - 1 : 0] row_tdata;
    
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
            //always @(posedge clk) row_adder_en_delay <= row_adder_en;
            
            for (c = 0; c < KERNEL_SIZE; c = c + 1) begin 
                pe #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .WEIGHT_WIDTH(WEIGHT_WIDTH)
                ) pe_inst (
                    .clk(clk),
                    .rstn(rstn),
                    .pe_en(en),
                    .pe_input(vertical_pixel_bus[(r * ROW_STRIDE) + ((KERNEL_SIZE - 1 - c) * DATA_WIDTH) +: DATA_WIDTH]),
                    // Input comes from previous row's output bus
                   // .pe_input(vertical_pixel_bus[(r * ROW_STRIDE) + (c * DATA_WIDTH) +: DATA_WIDTH]),
                    .pe_weight(weightsIn[(r*KERNEL_SIZE + c)*WEIGHT_WIDTH +: WEIGHT_WIDTH]),
                    // Output goes to next row's input bus
                    //.pe_pixel_out(vertical_pixel_bus[((r+1) * ROW_STRIDE) + (c * DATA_WIDTH) +: DATA_WIDTH]),
                    .pe_output(products[c*PRODUCT_WIDTH +: PRODUCT_WIDTH]),
                    // Keep output consistent with the input flip
                    .pe_pixel_out(vertical_pixel_bus[((r+1) * ROW_STRIDE) + ((KERNEL_SIZE - 1 - c) * DATA_WIDTH) +: DATA_WIDTH]),
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
                // write interface
                .adder_en(row_adder_en),
                .adder_dataIn(products),
                // read interface
		.m_axis_tready(row_tready[r]),
		.m_axis_tvalid(row_tvalid[r]),
		.m_axis_tdata(row_tdata[r * PARTIAL_SUM_WIDTH +: PARTIAL_SUM_WIDTH])
               // .adder_dataOut(dataOut[r*SUM_WIDTH +: SUM_WIDTH]) // Connect to intermediate wire, NOT final output
            );
        end
    endgenerate
    
    // 3. The Crossbar - Multiplexes kernel size rows into 1 final output
    crossbar#(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(PARTIAL_SUM_WIDTH)
    ) crossbar_inst (
        .clk(clk),
        .rstn(rstn),

        // Slave side: connected to all the row adders
        .s_axis_tvalid(row_tvalid),
        .s_axis_tdata (row_tdata),
        .s_axis_tready(row_tready),

        // Master side: final output of the pe_wrapper
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tdata (m_axis_tdata),
        .m_axis_tready(m_axis_tready)
    );
    
    
endmodule
