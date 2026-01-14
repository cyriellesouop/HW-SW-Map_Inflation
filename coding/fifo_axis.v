`timescale 1ns/1ps

module fifo_axis
 #(
    parameter DATAWIDTH = 8,
    parameter DEPTH = 4,
    parameter PTR_WIDTH = 2
  )
  (
    input clk,
    input rstn,
    //write interface
    input s_tvalid,
    input [DATAWIDTH-1:0] s_tdata,
    output s_tready ,

    // read interface
    input m_tready,
    output  [DATAWIDTH-1:0] m_tdata ,
    output   m_tvalid
  );

  wire full;
  wire empty;

  assign m_tvalid = ~empty;

  assign s_tready = ~full;

    fifo #(.DATAWIDTH(DATAWIDTH), .DEPTH(DEPTH), .PTR_WIDTH(PTR_WIDTH ) )

   fifo_inst (
         .clk(clk),
         .rstn(rstn),

         .dataIn(s_tdata),
         .full(full),
         .WR(s_tvalid),

         .dataOut( m_tdata),
         .empty(empty),
         .RD(m_tready)
  );


   endmodule
