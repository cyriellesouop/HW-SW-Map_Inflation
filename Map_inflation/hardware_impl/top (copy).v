`timescale 1ns/1ps

module top

#(
   // Parameters
    parameter KERNEL_SIZE  = 3,
    parameter DATA_WIDTH   = 8,
    parameter WEIGHT_WIDTH = 8,
    parameter DEPTH       = 4,    // Depth of each FIFO
    parameter PTR_WIDTH   = 2,    // Log2 of DEPTH
    parameter LATENCY = 2         //adder_tree latency
 
)(
    input clk,
    input rstn,

    // AXI Stream Slave Interface (Input)
    // The width is (KERNEL_SIZE * DATAWIDTH)
    input [(KERNEL_SIZE*DATA_WIDTH)-1:0] s_axis_tdata,
    input                               s_axis_tvalid,
    output                              s_axis_tready,

    // Weight configuration input
    input  [(WEIGHT_WIDTH * KERNEL_SIZE * KERNEL_SIZE) - 1 : 0] weightsIn,

    // Interface to read from the final dataOut
    input  [KERNEL_SIZE-1:0]            m_axis_tready, // One for each FIFO
    output [(KERNEL_SIZE*DATA_WIDTH)-1:0] m_axis_tdata,
    output [KERNEL_SIZE-1:0]            m_axis_tvalid
);


    // Signals between axis_unpack_data and pe_wrapper
    wire [KERNEL_SIZE-1:0]              m_axis_tready_unpack;
    wire [(KERNEL_SIZE*DATA_WIDTH)-1:0] m_axis_tdata_unpack;
    wire [KERNEL_SIZE-1:0]              m_axis_tvalid_unpack;

   
   // PE wrapper control signals
    wire ready_pe_wrapper;  //ready signal for pe_wrapper
    wire pe_en;
    wire pe_done;
	    


    // PE wrapper enable: assert when all FIFOs have valid data AND PE is ready
    assign pe_en = ( m_axis_tvalid_unpack) && ready_pe_wrapper;
    
    // FIFO read enable: all FIFOs are read together when PE accepts data
    // This ensures synchronized consumption from all FIFOs
    assign fifo_m_tready = {KERNEL_SIZE{pe_en}};


    // Instantiate the unpack Module to spit the input data into FIFO
    axis_unpack_data #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(FIFO_DEPTH),
        .PTR_WIDTH(PTR_WIDTH)
    ) unpack_inst (
        .clk(clk),
        .rstn(rstn),

        // Slave Port (Filling side)
        .s_axis_tdata (s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),

        // Master Port (Reading side)
        .m_axis_tready(m_axis_tready_unpack),
        .m_axis_tdata (m_axis_tdata_unpack),
        .m_axis_tvalid(m_axis_tvalid_unpack)
    );


    // Instantiate the pe_wrapper module that perform the dotProduct operation on each input coming from the unpack output 
    pe_wrapper #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .WEIGHT_WIDTH(WEIGHT_WIDTH)
    ) pe_wrapper_inst  (
        .clk(clk),
        .rstn(rstn),

	//inputs
        .en(pe_en),
        .dataIn(m_axis_tdata_unpack),
        .weightsIn(weightsIn),

	//outputs
        .dataOut(m_axis_tdata),
        .dataOut_done(pe_done),
	.ready(ready_pe_wrapper)
    );

endmodule
i
