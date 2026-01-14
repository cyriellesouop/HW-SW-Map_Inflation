`timescale 1ns/1ps

module grayscale 
 #(
     parameter DATA_WIDTH = 8
  )
  (
     input clk,
     input rstn,

     // slave inteface
     input [3*DATA_WIDTH-1:0] s_tdata_gray, // {R,G,B}
     input s_tvalid_gray,
     output reg s_tready_gray,

     //master interface
     output reg [DATA_WIDTH-1:0] m_tdata_gray, // Grayscale pixel
     output reg m_tvalid_gray,
     input m_tready_gray
   );

   
   //stage 1: result from weighted multiplication of  red , green and blue channel separetely
   reg valid_stage1; 
   reg[(2*DATA_WIDTH-1):0] R_res_stage1;
   reg[(2*DATA_WIDTH-1):0] G_res_stage1;
   reg[(2*DATA_WIDTH-1):0] B_res_stage1 ;

   //stage2 : addition of weighted multiplication
   reg valid_stage2; 
   reg [2*DATA_WIDTH:0] gray_sum_stage2;

   // Stage 3: shift and output
   reg valid_stage3;
   reg [DATA_WIDTH-1:0] gray_final_stage3;
   

   // split the input pixel into R, G, B channels
   wire [DATA_WIDTH-1:0] R, G, B; 

   assign R = s_tdata_gray[3*DATA_WIDTH-1 : 2*DATA_WIDTH]; // extract Red color code from the input RGB
   assign G = s_tdata_gray[2*DATA_WIDTH-1 :DATA_WIDTH]; // extract Green color code from the input RGB
   assign B = s_tdata_gray[DATA_WIDTH-1 :0]; // extract Green color code from the input RGB


  // -------------------------------------------------------------------------
  // Stage 1: Parallel multiplication 
  // -------------------------------------------------------------------------
   always @(posedge clk) begin
      if (~rstn) begin
	 s_tready_gray <= 0;

         R_res_stage1 <= 0;
         G_res_stage1 <= 0;
         B_res_stage1 <= 0;
         valid_stage1 <= 0;
        end
       	else begin

            s_tready_gray <= m_tready_gray;

            if (s_tvalid_gray && s_tready_gray) begin
                // parallel multiply stage
                R_res_stage1 <= R * 8'd77;   
                G_res_stage1 <= G * 8'd150;  
                B_res_stage1 <= B * 8'd29; 

                valid_stage1 <= 1'b1;
            end
	    else begin
                valid_stage1 <= 1'b0;
            end
        end
    end

  // -------------------------------------------------------------------------
  // Stage 2: addition of the weigthed
  // -------------------------------------------------------------------------
 
  always @(posedge clk) begin
      if (~rstn) begin
           gray_sum_stage2 <= 0;
           valid_stage2 <= 0;
      end 
      else begin
           if (valid_stage1) begin
                gray_sum_stage2 <= R_res_stage1 + G_res_stage1 + B_res_stage1;
                valid_stage2 <= 1'b1;
           end 
	   else begin
                valid_stage2 <= 1'b0;
           end
       end
   end


 // -------------------------------------------------------------------------
// Stage 3 + 4 : manage shift and output register in one pipeline.
// -------------------------------------------------------------------------

always @(posedge clk) begin
    if (~rstn) begin
        m_tdata_gray  <= 0;
        m_tvalid_gray <= 0;
    end else begin
        if (valid_stage2) begin
            // Shift + directly assign to the output master_tdata
            m_tdata_gray  <= gray_sum_stage2 >> 8;
            m_tvalid_gray <= 1'b1;
        end else if (m_tvalid_gray && m_tready_gray) begin
             // Output available and accepted so we clear the master_tvalid
            m_tvalid_gray <= 1'b0;
        end
    end
end

  
  /*
// -------------------------------------------------------------------------
// Stage 3: shift operation on the sum 
// -------------------------------------------------------------------------

  always @(posedge clk) begin
      if (~rstn) begin
          gray_final_stage3 <= 0;
          valid_stage3 <= 0;
      end 
      else begin
          if (valid_stage2) begin
              gray_final_stage3 <= gray_sum_stage2 >> 8;
              valid_stage3 <= 1'b1;
          end
          else begin
              valid_stage3 <= 1'b0;
          end
      end
   end

// -------------------------------------------------------------------------
// Stage 4: manage the output registers
// -------------------------------------------------------------------------
  always @(posedge clk) begin
      if (~rstn) begin
          m_tvalid_gray <= 1'b0; 
	  m_tdata_gray <= 1'b0;
      end
      else begin
	 if (valid_stage3) begin
              m_tdata_gray  <= gray_final_stage3;
              m_tvalid_gray <= 1'b1;
         end
	 else if (m_tvalid_gray && m_tready_gray) begin
           // Output available and accepted so we clear the master_tvalid
	     	 m_tvalid_gray <= 1'b0;
         end
      end
   end

   
  */

endmodule
