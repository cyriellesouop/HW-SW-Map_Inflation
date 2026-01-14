`timescale 1ns/1ps

module testbench;

  parameter DATA_WIDTH = 16;
  localparam  PERIOD = 4;
  reg clk=0;
  reg rstn;

  //slave interface (inputs)
  reg [3*DATA_WIDTH-1:0] s_tdata_top ;
  reg s_tvalid_top;
  wire s_tready_top;

  //master interface (outputs of the system)
  wire [DATA_WIDTH-1:0] m_tdata_top;
  wire m_tvalid_top
  reg m_tready_top;


  
  top #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH) , .PTR_WIDTH(PTR_WIDTH)) 
  
  DUT (
    .clk(clk),
    .rstn(rstn),

    .s_tdata_top(s_tdata_top),
    .s_tvalid_top(s_tvalid_top),
    .s_tready_top(s_tready_top),

    .m_tdata_top(m_tdata_top),
    .m_tvalid_top(m_tvalid_top),
    .m_tready_top(m_tready_top)
  );

  
  always #(PERIOD/2) clk = ~clk; 

  
  initial begin
    
       rstn = 0;
       s_tdata_top = 0;
       s_tvalid_top = 0;
     //  m_tready_top = 0; 

       #20;
       rstn = 1;
       repeat(2)@(posedge clk);
       m_tready_top = 1;
       @(posedge clk);

           // Loop over RGB ranges
       for (R_val = 8'd24; R_val < 8'd100; R_val = R_val +  8'd25) begin
          for (G_val = 8'd99; G_val < 8'd200; G_val = G_val +  8'd25) begin
             for (B_val = 8'd174; B_val < 8'd255; B_val = B_val +  8'd25) begin

               // Apply input
               s_tdata_top = {R_val[7:0], G_val[7:0], B_val[7:0]};
               s_tvalid_top = 1'b1;

               // Wait for ready
               wait(s_tready_top);
               @(posedge clk);
               s_tvalid_top =0;

               // Wait for output valid
               wait(m_tvalid_top);
	       expected_gray = gray_expected(R_val, G_val, B_val);
	       @(posedge clk);

	     end
	   end
	 end




  end


endmodule
