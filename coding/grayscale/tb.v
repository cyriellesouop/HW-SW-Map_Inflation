`timescale 1ns/1ps

module fifo_tb;

  // Parameters
  parameter DATAWIDTH = 8;
  parameter DEPTH = 4;
  parameter PERIOD = 4;

  reg clk=0;
  reg rstn;
  reg WR;
  reg  RD;
  reg [DATAWIDTH-1:0] dataIn;
  wire [DATAWIDTH-1:0] dataOut;
  wire full;
  wire  empty;

  
  fifo #(.DATAWIDTH(DATAWIDTH), .DEPTH(DEPTH))
  
   DUT(
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

  initial begin
    
    // Initialize
    rstn = 0;
    WR = 0;
    RD = 0;
    dataIn = 0;

    #10;
    rstn = 1;
    repeat(2) @(posedge clk);

    //  write values into FIFO
    i=0;
    while(i< (2**DATAWIDTH)-1) begin
   // for ( i = 0; i < (2**DATAWIDTH)-1; i = i + 1) begin  
      @(posedge clk);
      if (!full) begin
        WR = 1;
        dataIn = i;
	i = i+1;
	
        $display("[%0t] write display: dataIn = %0d, full = %0b , empty = %0b", $time, dataIn, full, empty);
//	i = i+1;
	
      end
     
      else begin
	 $display("[%0t] fifo full, cannot write : dataIn = %0d, full = %0b , empty = %0b", $time, i, full, empty);
      //  $display("[%0t] fifo full, cannot write %0d", $time, i);
      end
      
      @(posedge clk);
      WR = 0;

    end
   end

    // read values into FIFO
  initial begin
    repeat(15) @(posedge clk);
    while (!empty) begin
      @(posedge clk);
      RD = 1;
      @(posedge clk);
      RD = 0;
      $display("[%0t] read display :  dataOut= %0d, full = %0b, empty = %0b", $time, dataOut, full, empty);
    end

   
    #100 $finish;
  end

endmodule

