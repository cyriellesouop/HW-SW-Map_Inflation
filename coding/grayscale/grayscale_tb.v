`timescale 1ns/1ps

module grayscale_tb;

  parameter DATA_WIDTH = 8;
  localparam PERIOD = 4;

  // Inputs
  reg clk=0;
  reg rstn;

  reg [3*DATA_WIDTH-1:0] s_tdata_gray;
  reg s_tvalid_gray;
  reg m_tready_gray;

  // Outputs
  wire s_tready_gray;
  wire [DATA_WIDTH-1:0] m_tdata_gray;
  wire m_tvalid_gray;


  reg [DATA_WIDTH-1:0] expected_gray=0;
  reg [15:0] error_count=0;

  // Instantiate the grayscale module
  grayscale #(.DATA_WIDTH(DATA_WIDTH)) 
 
 DUT (
    .clk(clk),
    .rstn(rstn),

    .s_tdata_gray(s_tdata_gray),
    .s_tvalid_gray(s_tvalid_gray),
    .s_tready_gray(s_tready_gray),

    .m_tdata_gray(m_tdata_gray),
    .m_tvalid_gray(m_tvalid_gray),
    .m_tready_gray(m_tready_gray)
  );

  reg [DATA_WIDTH-1:0] R_val, G_val, B_val;
  reg [DATA_WIDTH-1:0] total_tests = 0;

  always #(PERIOD/2) clk = ~clk; 
 


  function [DATA_WIDTH-1:0] gray_expected; 
       input [DATA_WIDTH-1:0] R, G, B;
       reg [2*DATA_WIDTH:0] gray_sum;  // enough bits to hold full sum before shifting
       begin
          // Weighted sum — same coefficients as DUT
          gray_sum = (R * 77) + (G * 150) + (B * 29);
    
          // Final grayscale value (8-bit)
           gray_expected = gray_sum >> 8;
       end
  endfunction



  initial begin
    // Initialize signals
    rstn = 0;
    s_tdata_gray = 0;
    s_tvalid_gray = 0;
    m_tready_gray = 1; // always ready to accept

    // Apply reset
    #20;
    rstn = 1;
   repeat(2)@(posedge clk);



    // Loop over RGB ranges
    for (R_val = 8'd24; R_val < 8'd100; R_val = R_val +  8'd25) begin
      for (G_val = 8'd99; G_val < 8'd200; G_val = G_val +  8'd25) begin
        for (B_val = 8'd174; B_val < 8'd255; B_val = B_val +  8'd25) begin
          
          // Apply input
          s_tdata_gray = {R_val[7:0], G_val[7:0], B_val[7:0]};
          s_tvalid_gray = 1'b1;

          // Wait for ready
          wait(s_tready_gray);
          @(posedge clk);
          s_tvalid_gray = 0;

          // Wait for output valid
          wait(m_tvalid_gray);

	   if (m_tdata_gray !== expected_gray) begin
              $display("MISMATCH: RGB = (%0d,%0d,%0d) -> DUT=%0d, | Expected=%0d", R_val, G_val, B_val, m_tdata_gray, expected_gray);
              error_count = error_count + 1;
          end
          else begin
             $display("PASS : Input RGB = (%0d,%0d,%0d) -> DUT = %0d |Expected=%0d ", R_val, G_val, B_val, m_tdata_gray, expected_gray);
          end

	  // Compute expected
          expected_gray = gray_expected(R_val, G_val, B_val);
          @(posedge clk);


        //  $display("Input RGB = (%0d,%0d,%0d) -> Grayscale = %0d", R_val, G_val, B_val, m_tdata_gray);
	/*  if (m_tdata_gray !== expected_gray) begin
              $display("MISMATCH: RGB = (%0d,%0d,%0d) -> DUT=%0d, | Expected=%0d", R_val, G_val, B_val, m_tdata_gray, expected_gray);
              error_count = error_count + 1;
          end 
	  else begin
             $display("PASS : Input RGB = (%0d,%0d,%0d) -> Grayscale = %0d", R_val, G_val, B_val, m_tdata_gray);
          end */

          total_tests = total_tests + 1;
          @(posedge clk);
        end
      end
    end

    if (error_count == 0)
       $display("All grayscale %0d tests PASSED!", total_tests);
    else
       $display("%0d tests FAILED.", error_count);
 
   #200 $finish;
  end

endmodule

