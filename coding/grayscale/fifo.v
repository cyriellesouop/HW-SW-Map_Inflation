`timescale 1ns/1ps

module fifo
 #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 4,
    parameter PTR_WIDTH = 2
  )
  (
    input clk,
    input rstn,
    //write interface
    input WR,
    input [DATA_WIDTH-1:0] dataIn,
    output  full,

    // read interface
    input RD,
    output reg [DATA_WIDTH-1:0]  dataOut,
    output   empty
  );

   reg [PTR_WIDTH-1 : 0] wr_addr;
   reg [PTR_WIDTH-1 : 0] rd_addr;

   reg [DATA_WIDTH-1:0] MEM [DEPTH-1:0];
   
//   reg [$clog2(DEPTH)-1 : 0] wr_addr;
   reg wr_cnt;

  // reg [$clog2(DEPTH)-1 : 0] rd_addr;
   reg  rd_cnt;





  //write interface
  always @(posedge clk ) begin
	if(rstn) begin
	    
	    if(WR) begin
		  if(~full ) begin
		     MEM[wr_addr] <= dataIn;
		   //  wr_addr <= wr_addr + 1 ;
		     if(wr_addr == DEPTH-1 )  begin
			wr_addr <= 0 ;
			if(wr_cnt==0)
			   wr_cnt <= 1;
		        else 
			   wr_cnt <= 0;
		     end
	             else
			  wr_addr <= wr_addr + 1 ;

                  end	    
            end
      end
 end
   //read interface
   //
   always @(posedge clk ) begin
        if(rstn) begin

		if(RD) begin
		   if(~empty) begin
                      dataOut <=  MEM[rd_addr];
                      
		      if (rd_addr == DEPTH-1) begin
			      rd_addr <=0;
			      if(rd_cnt==0)
			          rd_cnt <= 1;
		              else
			          rd_cnt <=0;
		      end
		      else 
			    rd_addr <= rd_addr +1;
                  end
            end
        end
   end
   
   //intialization
     always @(posedge clk ) begin
        if(!rstn) begin
           wr_cnt <= 0;
           rd_cnt <= 0;
           wr_addr <= 0;
           rd_addr <= 0;
        end
     end

   //full and empty signal

          assign  empty =(wr_addr == rd_addr) && (wr_cnt == rd_cnt) ;
	  assign full = (wr_addr == rd_addr) &&  (wr_cnt != rd_cnt );
                  
   endmodule





