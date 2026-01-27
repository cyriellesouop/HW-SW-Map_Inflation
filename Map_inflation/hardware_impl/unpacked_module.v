`timescale 1ns/1ps

module unpacker_module #(
    parameter KERNEL_SIZE = 3,           // Number of output channels
    parameter DATA_WIDTH = 8,            // Width of each unpacked element
    parameter FIFO_DEPTH = 4,            // Depth of each FIFO
    parameter FIFO_PTR_WIDTH = 2         // Pointer width for FIFO
)(
    input  clk,
    input  rstn,
    
    // AXI Stream Slave Interface (input)
    input   s_axis_tvalid,
    input   [KERNEL_SIZE * DATA_WIDTH - 1 : 0] s_axis_tdata,
    output reg s_axis_tready,
    
    // AXI Stream Master Interfaces (outputs) - one per kernel element
    output reg [KERNEL_SIZE-1:0] m_axis_tvalid,
    output reg [KERNEL_SIZE * DATA_WIDTH - 1 : 0] m_axis_tdata,
    input  [KERNEL_SIZE-1:0] m_axis_tready
);

    // Internal Signals
    localparam TOTAL_WIDTH = KERNEL_SIZE * DATA_WIDTH;
    
    // Unpacked input data elements
    wire [DATA_WIDTH-1:0] unpacked_data [0:KERNEL_SIZE-1];
    
    // FIFO slave interfaces (write side)
    wire [KERNEL_SIZE-1:0] fifo_s_tvalid;
    wire [KERNEL_SIZE-1:0] fifo_s_tready;
    wire [DATA_WIDTH-1:0] fifo_s_tdata [0:KERNEL_SIZE-1];
    
    // FIFO master interfaces (read side)
    wire [KERNEL_SIZE-1:0] fifo_m_tvalid;
    wire [KERNEL_SIZE-1:0] fifo_m_tready;
    wire [DATA_WIDTH-1:0] fifo_m_tdata [0:KERNEL_SIZE-1];
    
    genvar i;
    reg[KERNEL_SIZE:0] j;
    
    // Unpack input data into individual elements
    generate
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin : unpack_input
            assign unpacked_data[i] = s_axis_tdata[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH];
        end
    endgenerate
    
    //------------Slave ready signal - ready only when ALL FIFOs can accept data
    reg all_fifos_ready;
    
    always @(*) begin
        all_fifos_ready = 1'b1;
        for (j = 0; j < KERNEL_SIZE; j = j + 1) begin
            all_fifos_ready = all_fifos_ready & fifo_s_tready[j];
        end
    end
    
    assign s_axis_tready = all_fifos_ready;
    
    // --------------------------------------------------------------
    // Write to all FIFOs simultaneously when input is valid and ready
    // --------------------------------------------------------------
    generate
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin : write_enable
            assign fifo_s_tvalid[i] = s_axis_tvalid & s_axis_tready;
            assign fifo_s_tdata[i] = unpacked_data[i];
        end
    endgenerate
    
    // --------------------------------------------------------------
    // Instantiate FIFOs - one for each kernel element
    // --------------------------------------------------------------
    generate
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin : fifo_instances
            fifo_axis #(
                .DATAWIDTH(DATA_WIDTH),
                .DEPTH(FIFO_DEPTH),
                .PTR_WIDTH(FIFO_PTR_WIDTH)
            ) fifo_inst (
                .clk(clk),
                .rstn(rstn),
                // Write interface (slave)
                .s_tvalid(fifo_s_tvalid[i]),
                .s_tdata(fifo_s_tdata[i]),
                .s_tready(fifo_s_tready[i]),
                // Read interface (master)
                .m_tready(m_axis_tready[i]),
                .m_tdata(fifo_m_tdata[i]),
                .m_tvalid(fifo_m_tvalid[i])
            );
        end
    endgenerate
    
    // --------------------------------------------------------------
    // Pack FIFO outputs into master interface outputs
    // --------------------------------------------------------------
    generate
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin : pack_output
            assign m_axis_tvalid[i] = fifo_m_tvalid[i];
            assign m_axis_tdata[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] = fifo_m_tdata[i];
        end
    endgenerate

endmodule
