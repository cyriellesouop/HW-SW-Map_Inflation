`timescale 1ns/1ps

module top_fifo #(
    parameter KERNEL_SIZE = 3,
    parameter DATA_WIDTH   = 8,
    parameter FIFO_DEPTH  = 4,
    parameter PTR_WIDTH   = 2
)(
    input clk,
    input rstn,

    // --- AXI Stream Slave Interface (Connects to your Master) ---
    input  [(KERNEL_SIZE*DATA_WIDTH)-1:0] s_axis_tdata,
    input                                s_axis_tvalid,
    output                               s_axis_tready,

    // --- Interface for the logic that will USE the FIFO data ---
    // These would connect to your Kernel/Processing logic
    input  [KERNEL_SIZE-1:0]             m_axis_tready,
    output [(KERNEL_SIZE*DATA_WIDTH)-1:0] m_axis_tdata,
    output [KERNEL_SIZE-1:0]             m_axis_tvalid
);

    // Instantiate the Splitter Module
    // This acts as the "Glue" between the Master and the individual FIFOs
    axis_unpack_data #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(FIFO_DEPTH),
        .PTR_WIDTH(PTR_WIDTH) // Automatic calculation of pointer width
    ) u_splitter (
        .clk(clk),
        .rstn(rstn),

        // Slave Port (Filling side)
        .s_axis_tdata (s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),

        // Master Port (Reading side)
        .m_axis_tready(m_axis_tready),
        .m_axis_tdata (m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid)
    );

endmodule
