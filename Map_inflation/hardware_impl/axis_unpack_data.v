`timescale 1ns/1ps

module axis_unpack_data #(
    parameter KERNEL_SIZE = 3,         // Number of FIFOs
    parameter DATA_WIDTH   = 8,         // Width of each slice
    parameter DEPTH       = 4,        // Depth of each FIFO
    parameter PTR_WIDTH   = 2          // Log2 of DEPTH
    
)(
    input clk,
    input rstn,

    // AXI Stream Slave Interface (Input)
    // The width is (KERNEL_SIZE * DATAWIDTH)
    input [(KERNEL_SIZE*DATA_WIDTH)-1:0] s_axis_tdata,
    input                               s_axis_tvalid,
    output                              s_axis_tready,

    // Interface to read from the FIFOs (Master-like outputs)
    input  [KERNEL_SIZE-1:0]            m_axis_tready, // One for each FIFO
    output [(KERNEL_SIZE*DATA_WIDTH)-1:0] m_axis_tdata,
    output [KERNEL_SIZE-1:0]            m_axis_tvalid
);

    // Internal wires to connect to FIFO slave ports
    wire [KERNEL_SIZE-1:0] fifo_s_tready;
    
    // --- 1. Control Logic (Synchronized Handshaking) ---
    // The input is ready ONLY if all instantiated FIFOs are ready.
    // This prevents one FIFO from overflowing while others are empty.
    assign s_axis_tready = &fifo_s_tready; 

    // --- 2. Data Splitting and FIFO Instantiation ---
    genvar i;
    generate
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin 
            
            fifo_axis #(
                .DATAWIDTH(DATA_WIDTH),
                .DEPTH(DEPTH),
                .PTR_WIDTH(PTR_WIDTH)
            ) fifo_inst (
                .clk(clk),
                .rstn(rstn),        
                // Slave interface (Connected to splitter)
                // Only push data if the global s_axis_tvalid is high 
                // AND all other FIFOs can accept data
                .s_tvalid(s_axis_tvalid && s_axis_tready),
                .s_tdata (s_axis_tdata[i*DATA_WIDTH +: DATA_WIDTH]),
                .s_tready(fifo_s_tready[i]),

                // Master interface (Exposed to the next module)
                .m_tready(m_axis_tready[i]),
                .m_tdata (m_axis_tdata[i*DATA_WIDTH +: DATA_WIDTH]),
                .m_tvalid(m_axis_tvalid[i] )
            );
        end
    endgenerate

endmodule
