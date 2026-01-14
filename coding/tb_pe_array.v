`timescale 1ns/1ps

module tb_pe_array;

    // Parameters 
    parameter WEIGHT_WIDTH = 1;
    parameter DATA_WIDTH   = 8;
    parameter KERNEL_SIZE  = 2;
    localparam KERNEL_DIM  = KERNEL_SIZE*KERNEL_SIZE;
    localparam RESULT_WIDTH = DATA_WIDTH + WEIGHT_WIDTH; // match the DUT +1
    localparam PERIOD = 4;

    // DUT signals
    reg clk=0;
    reg rstn;
    reg wr_weight_en;
    reg [(WEIGHT_WIDTH*KERNEL_DIM)-1:0] weight_array;
    reg wr_dataIn_en;
    reg [(DATA_WIDTH*KERNEL_DIM)-1:0] dataIn;

    wire wr_weight_done;
    wire pe_array_done;
    wire [(RESULT_WIDTH*KERNEL_SIZE)-1:0] dataOut;

    
    reg [DATA_WIDTH-1:0] pixel_array [0:KERNEL_DIM-1];
    reg [KERNEL_DIM-1:0] i, j;
    integer error_count = 0;
 
    // --------Instantiate the DUT-------------
    pe_array #(
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE)
    ) DUT (
        .clk(clk),
        .rstn(rstn),
        .weight_array(weight_array),
        .wr_weight_en(wr_weight_en),
        .dataIn(dataIn),
	.wr_dataIn_en(wr_dataIn_en),
        .wr_weight_done(wr_weight_done),
        .pe_array_done(pe_array_done),
        .dataOut(dataOut)
    );



 
    always #(PERIOD/2) clk = ~clk;

    // --------Verification function-------------
// place this inside your testbench (adjust widths/params as already defined)
 function [(RESULT_WIDTH*KERNEL_SIZE)-1:0] verify;
      input [(DATA_WIDTH*KERNEL_SIZE)-1:0] dataIn_local;      // NOTE: only KERNEL_SIZE columns
      input [(WEIGHT_WIDTH*KERNEL_DIM)-1:0] weight_local;    // weights still KERNEL_DIM (N*N)
     
      reg [KERNEL_DIM-1:0] idx, r;
      reg [KERNEL_SIZE-1:0] c;

      reg [DATA_WIDTH-1:0]   dataCol      [0:KERNEL_SIZE-1];    // one data per column
      reg [WEIGHT_WIDTH-1:0] weight_arr   [0:KERNEL_DIM-1];
      reg [RESULT_WIDTH-1:0] result_wire_ver [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1];
      reg [RESULT_WIDTH-1:0] prev_result_ver;

   begin
    // Unpack column data (external input provides one value per column)
      for (c = 0; c < KERNEL_SIZE; c = c + 1) begin
         dataCol[c] = dataIn_local[(c+1)*DATA_WIDTH-1 -: DATA_WIDTH];
      end

    // Unpack weights (one per PE, row-major order)
      for (r = 0; r < KERNEL_DIM; r = r + 1) begin
         weight_arr[r] = weight_local[(r+1)*WEIGHT_WIDTH-1 -: WEIGHT_WIDTH];
      end

    // Simulate 2D systolic array (row-major)
      for (r = 0; r < KERNEL_SIZE; r = r + 1) begin
         for (c = 0; c < KERNEL_SIZE; c = c + 1) begin
            idx = r * KERNEL_SIZE + c;                       // index into weight array
            // dataVal for any row is the column's external data (forwarded down)
            // data_val = dataCol[c]
            if (r == 0)
                prev_result_ver = {RESULT_WIDTH{1'b0}};      // top row starts with 0
            else
                prev_result_ver = result_wire_ver[r-1][c];   // from the PE above (same column)
	
            // MAC: prev + data * weight
            result_wire_ver[r][c] = prev_result_ver + (dataCol[c] * weight_arr[idx]);
         end
      end

    // Pack last row results (row = KERNEL_SIZE-1) into a wide vector, same order as DUT
      verify = { (RESULT_WIDTH*KERNEL_SIZE){1'b0} }; // clear
      for (c = 0; c < KERNEL_SIZE; c = c + 1) begin
         verify[(c+1)*RESULT_WIDTH-1 -: RESULT_WIDTH] = result_wire_ver[KERNEL_SIZE-1][c];
      end
    end
  endfunction

    initial begin
        // Reset
        rstn = 0;
        wr_weight_en = 0;
        dataIn = 0;
        weight_array = 0;
	wr_dataIn_en = 0;
        repeat(2)@(posedge clk);
        rstn = 1;
        repeat(2)@(posedge clk);
        /*
	1, 2, 3,
        4, 5, 6,
        7, 8, 9
	*/
         pixel_array[0] = 8'd1;   // pixel 0
         pixel_array[1] = 8'd2;   // pixel 1
         pixel_array[2] = 8'd3;   // pixel 2
         pixel_array[3] = 8'd4;   // pixel 3
        /* pixel_array[4] = 8'd5;   // pixel 4
         pixel_array[5] = 8'd6;   // pixel 5
         pixel_array[6] = 8'd7;   // pixel 6
         pixel_array[7] = 8'd8;   // pixel 7
         pixel_array[8] = 8'd9;   // pixel 8
       */
       	// Apply weights
	weight_array = {1'b1, 1'b1, 1'b1, 1'b1};
       // weight_array = {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1}; // example weights
        wr_weight_en = 1;
        repeat(2)@(posedge clk);
	wr_dataIn_en = 1;
	repeat(2)@(posedge clk);
        
	//to uncomment later
	
         /*
       // Run several test cases with random data
        for (i = 0; i < 10; i=i+1) begin
        // Generate random 9 values between 0 and 16
            for (j = 0; j < KERNEL_DIM; j=j+1) begin
                pixel_array[j] = $urandom_range(0, 16);
            end

            // Pack 9 random pixels into dataIn
             dataIn = { pixel_array[0],
                        pixel_array[1],
                        pixel_array[2],
                        pixel_array[3],
                        pixel_array[4],
                        pixel_array[5],
                        pixel_array[6],
                        pixel_array[7],
                        pixel_array[8] };
*/
            
            dataIn = { pixel_array[0],
                        pixel_array[1],
                        pixel_array[2],
                        pixel_array[3]};

             // Apply data
             repeat(2) @(posedge clk);

             // Wait until DUT asserts pe_array_done
             wait(pe_array_done == 1);
             repeat(8)@(posedge clk);

        // -------Verification--------------
       	     if (dataOut === verify(dataIn, weight_array)) begin
	         $display("TEST %0d PASSED! Random data: %0b", i, dataIn);
		 $display("Expected: %b", verify(dataIn, weight_array));
		 $display("DUT     : %b", dataOut);

           // $display("TEST PASSED! dataOut matches expected result.");
             end else begin
		 error_count = error_count + 1;
                 $display("TEST %0d FAILED!Random data: %0b", i, dataIn );
                 $display("Expected: %d", verify(dataIn, weight_array));
                 $display("DUT     : %d", dataOut);
             end
	     repeat(5) @(posedge clk);
//        end
	if(error_count === 0 )
            $monitor("%0t ALL THE TEST HAS PASSED !!! ", $time);

        #1000;
        $finish;
    end

endmodule

