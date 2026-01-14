`timescale 1ns/1ps

module top
 #(
     parameter DATA_WIDTH = 8,
     parameter DEPTH = 4,
     parameter PTR_WIDTH = 2
  )
  (
     input clk,
     input rstn,

     // slave inteface
     input [3*DATA_WIDTH-1:0] s_tdata_top, // {R,G,B}
     input s_tvalid_top,
     output reg s_tready_top,

     //master interface
     output reg [DATA_WIDTH-1:0] m_tdata_top, // Grayscale pixel
     output reg m_tvalid_top,
     input m_tready_top
   );

// fifo_In wires 
    wire m_tvalid_fifoIn;
    wire [(3*DATA_WIDTH)-1:0] m_tdata_fifoIn;
    wire m_tready_fifoIn;

// grayscale wires
   wire [(3*DATA_WIDTH)-1:0] s_tdata_gray;
   wire s_tvalid_gray;
   reg s_tready_gray;

   reg [DATA_WIDTH-1:0] m_tdata_gray;
   reg m_tvalid_gray;
   wire m_tready_gray;

 //fifo_out wires
   wire s_tvalid_fifoOut;
   wire s_tdata_fifoOut;
   wire s_tready_fifoOut;


   assign m_tready_fifoIn = s_tready_gray;

   assign s_tdata_gray = m_tdata_fifoIn;
   assign s_tvalid_gray = m_tvalid_fifoIn;
   assign m_tready_gray = s_tready_fifoOut;

   assign s_tvalid_fifoOut = m_tvalid_gray;
   assign s_tdata_fifoOut = m_tdata_gray;

  
    

    //-------------fifoIn ---------------------------------------
    fifo_axis #(.DATA_WIDTH(3*DATA_WIDTH), .DEPTH(DEPTH) , .PTR_WIDTH(PTR_WIDTH))
        fifo_In(
                 .clk(clk),
	         .rstn(rstn),

		 .s_tvalid(s_tvalid_top),
		 .s_tdata(s_tdata_top), 
                 .s_tready(s_tready_top),

		 .m_tvalid(m_tvalid_fifoIn),
	         .m_tdata(m_tdata_fifoIn),
		 .m_tready(m_tready_fifoIn)
              );
      

    //-------------grayscale ---------------------------------------
    grayscale #(.DATA_WIDTH(DATA_WIDTH))
          grayscale_inst (
		
		   .clk(clk),
                   .rstn(rstn),

		   .s_tvalid_gray(s_tvalid_gray),
		   .s_tdata_gray(s_tdata_gray),
		   .s_tready_gray(s_tready_gray),

		   .m_tvalid_gray(m_tvalid_gray),
		   .m_tdata_gray(m_tdata_gray),
	           .m_tready_gray( m_tready_gray)
	);

     
     //-------------fifoOut ---------------------------------------
    fifo_axis #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH) , .PTR_WIDTH(PTR_WIDTH))
        fifo_Out(
                 .clk(clk),
                 .rstn(rstn),

                 .s_tvalid(s_tvalid_fifoOut ),
                 .s_tdata(s_tdata_fifoOut),    
                 .s_tready(s_tready_fifoOut),

                 .m_tvalid(m_tvalid_top),
                 .m_tdata(m_tdata_top),
                 .m_tready(m_tready_top)
         );


endmodule

