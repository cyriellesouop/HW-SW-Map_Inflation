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

  // Instantiate the grayscale module
  grayscale #(.DATA_WIDTH(DATA_WIDTH)) uut (
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
  integer total_tests = 0;

  always #(PERIOD/2) clk = ~clk; 
  

  initial begin
    // Initialize signals
    rstn = 0;
    s_tdata_gray = 0;
    s_tvalid_gray = 0;
    m_tready_gray = 1; // always ready to accept

    // Apply reset
    #20;
    rstn = 1;

    // Loop over RGB ranges
    for (R_val = 25; R_val <= 200; R_val = R_val + 25) begin
      for (G_val = 0; G_val <= 200; G_val = G_val + 15) begin
        for (B_val = 175; B_val <= 255; B_val = B_val + 25) begin
          
          // Apply input
          s_tdata_gray = {R_val[7:0], G_val[7:0], B_val[7:0]};
          s_tvalid_gray = 1'b1;

          // Wait for ready
          wait(s_tready_gray == 1);
          @(posedge clk);
          s_tvalid_gray = 0;

          // Wait for output valid
          wait(m_tvalid_gray == 1);
          @(posedge clk);

          $display("Input RGB = (%0d,%0d,%0d) -> Grayscale = %0d", R_val, G_val, B_val, m_tdata_gray);

          total_tests = total_tests + 1;
          @(posedge clk);
        end
      end
    end

    $display("All %0d test cases done!", total_tests);
   #200    $finish;
  end

endmodule

