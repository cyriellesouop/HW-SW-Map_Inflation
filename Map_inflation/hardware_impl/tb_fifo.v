`timescale 1ns/1ps

module tb_fifo;

  // Parameters
  parameter DATAWIDTH = 8;
  parameter DEPTH = 4;
  parameter PTR_WIDTH = 2;
  parameter PERIOD = 4;

  reg clk = 0;
  reg rstn;
  reg WR;
  reg RD;
  reg [DATAWIDTH-1:0] dataIn;
  wire [DATAWIDTH-1:0] dataOut;
  wire full;
  wire empty;

  fifo #(
	  .DATAWIDTH(DATAWIDTH),
	  .DEPTH(DEPTH),
	  .PTR_WIDTH (PTR_WIDTH )
  )
 
  DUT (
    .clk(clk),
    .rstn(rstn),
    .dataIn(dataIn),
    .full(full),
    .WR(WR),
    .dataOut(dataOut),
    .empty(empty),
    .RD(RD)
  );

  reg [DATAWIDTH-1:0] i;

  
  always #(PERIOD/2) clk = ~clk;

  // Write interface
  initial begin
    rstn = 0;
    WR = 0;
    RD = 0;
    //dataIn = 0;
    i = 0;

    #10;
    rstn = 1;
    repeat(2) @(posedge clk);

    while (i < ((2**DATAWIDTH)/2)-1) begin
      @(posedge clk);
      if (!full) begin
        WR = 1;
        dataIn = i;
	@(posedge clk);
        $display("[%0t] WRITE: WR = %b dataIn=%0d full=%b empty=%b", $time, WR, dataIn, full, empty);
        i = i + 1;
      end else begin
        WR = 0;
        $display("[%0t] FIFO FULL: WR= %b  dataIn=%0d full=%b empty=%b", $time, WR, i, full, empty);
      end
    end

    WR = 0;
  end

  // Read interface
  initial begin
    repeat(15) @(posedge clk);
// 
    while(!empty) begin
      @(posedge clk);
     // if (!empty) begin
        RD = 1;
        @(posedge clk);
        $display("[%0t] READ: RD= %b dataOut=%0d full=%b empty=%b", $time, RD, dataOut, full, empty);
        RD = 0;
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

