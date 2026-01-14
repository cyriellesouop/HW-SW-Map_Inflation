`timescale 1ns/1ps

module tb_fifo_axis;

  // Parameters
  parameter DATAWIDTH = 8;
  parameter DEPTH = 4;
  parameter  PTR_WIDTH = 2 ;
  parameter PERIOD = 4;

  reg clk = 0;
  reg rstn;
  /*
  reg WR;
  reg RD;
  reg [DATAWIDTH-1:0] dataIn;
  wire [DATAWIDTH-1:0] dataOut;
  wire full;
  wire empty;
*/
//slave
  reg s_tvalid;
  reg [DATAWIDTH-1:0] s_tdata;
  wire  s_tready;

  // master
  wire m_tvalid;
  wire [DATAWIDTH-1:0] m_tdata;
  reg m_tready; 

  fifo_axis #(
	  .DATAWIDTH(DATAWIDTH),
	  .DEPTH(DEPTH),
	  .PTR_WIDTH(PTR_WIDTH) 
  )
 
  DUT (
    .clk(clk),
    .rstn(rstn),

    //slave
    .s_tvalid(s_tvalid ),
    .s_tready(s_tready ),
    .s_tdata(s_tdata ),

    // master
    .m_tvalid(m_tvalid ),
    .m_tready(m_tready ),
    .m_tdata(m_tdata )
    /*
    .dataIn(dataIn),
    .full(full),
    .WR(WR),
    .dataOut(dataOut),
    .empty(empty),
    .RD(RD)

    */
  );

  reg [DATAWIDTH-1:0] i;

  
  always #(PERIOD/2) clk = ~clk;

  // Write interface
  initial begin
    rstn = 0;
    s_tvalid = 0;
    m_tready = 0;
    //dataIn = 0;
    i = 0;

    #10;
    rstn = 1;
    repeat(2) @(posedge clk);

    while (i < ((2**DATAWIDTH)/2)-1) begin
      @(posedge clk);
      if (s_tready) begin
        s_tvalid = 1;
        s_tdata = i;
	@(posedge clk);
        $display("[%0t] WRITE: s_tvalid = %b  s_tdata=%0d s_tready=%b m_tvalid=%b", $time, s_tvalid, s_tdata, s_tready, m_tvalid);
        i = i + 1;
      end else begin
        s_tvalid = 0;
        $display("[%0t] FIFO FULL: s_tvalid= %b  s_tdata=%0d s_tready=%b m_tvalid=%b", $time, s_tvalid, i, s_tready, m_tvalid);
      end
    end

    s_tvalid  = 0;
  end

  // Read interface
  initial begin
    repeat(15) @(posedge clk);
// 
    while (m_tvalid ) begin
      @(posedge clk);
     // if (!empty) begin
        m_tready = 1;
        @(posedge clk);
        $display("[%0t] READ: m_tready= %b m_tdata=%0d full=%b empty=%b", $time, m_tready, m_tdata, s_tready, m_tvalid);
        m_tready = 0;
        // extra delay to make reading slower
        repeat(3) @(posedge clk); 
     // end else begin
       // RD = 0; 
    //  end
    end
  end

  
  initial begin
    #10000 $finish;
  end

endmodule

