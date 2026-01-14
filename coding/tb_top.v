`timescale 1ns/1ps

module tb_top;

    // Parameters
    parameter PERIOD = 4;
    parameter WEIGHT_WIDTH = 1;
    parameter DATA_WIDTH   = 8;
    parameter KERNEL_SIZE  = 2;
    parameter ADDRESS_WIDTH = 5;

    // Inputs
    reg clk = 0;
    reg rstn;
    reg [(WEIGHT_WIDTH*KERNEL_SIZE*KERNEL_SIZE)-1:0] weight_array;
    reg wr_weight_en;
    reg fifoIn_axis_tvalid;
    reg [(DATA_WIDTH*KERNEL_SIZE*KERNEL_SIZE)-1:0] fifoIn_axis_tdata;
    reg fifoOut_axim_tready;
    reg is_last;

    // Outputs
    wire fifoIn_axis_tready;
    wire fifoOut_axim_tvalid;
    wire [(DATA_WIDTH+WEIGHT_WIDTH)+KERNEL_SIZE-1:0] fifoOut_axim_tdata;

    // Instantiate the top module
    top #(
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) DUT (
        .clk(clk),
        .rstn(rstn),
        .weight_array(weight_array),
        .wr_weight_en(wr_weight_en),
        .fifoIn_axis_tvalid(fifoIn_axis_tvalid),
        .fifoIn_axis_tdata(fifoIn_axis_tdata),
        .fifoIn_axis_tready(fifoIn_axis_tready),
        .fifoOut_axim_tvalid(fifoOut_axim_tvalid),
        .fifoOut_axim_tdata(fifoOut_axim_tdata),
        .fifoOut_axim_tready(fifoOut_axim_tready),
        .is_last(is_last)
    );

    // Clock generation
    always #(PERIOD/2) clk = ~clk; // 250 MHz clock

    // Reset sequence
    initial begin
        rstn = 0;
        wr_weight_en = 0;
        fifoIn_axis_tvalid = 0;
        fifoIn_axis_tdata = 0;
        fifoOut_axim_tready = 0;
        is_last = 0;
        repeat(3) @(posedge clk);
        rstn = 1;
	is_last = 0;
        repeat(4) @(posedge clk);

        // Load weights
        weight_array = 4'b1111; // example weights for 2x2 kernel
        wr_weight_en = 1;
        repeat(2) @(posedge clk);
       // wr_weight_en = 0;

       fifoOut_axim_tready = 1; // ready to accept output
       
         // Step 3: Begin feeding input data stream
        // ---------------------------------------------------
        // Each cycle we feed new input data (stream)
        // Data = 4 pixels packed into 32 bits:
        //  dataIn = {p1, p2, p3, p4} where each p is 8-bit
        // ---------------------------------------------------

        fifoOut_axim_tready = 1; // ready for output anytime

        // Wait a few cycles before sending input
        repeat(3) @(posedge clk);

        // Input frame sequence:
        // First “row” input: (5, 1)
        fifoIn_axis_tdata = 32'b00000001000001000000000100000101; 
        fifoIn_axis_tvalid = 1;
        @(posedge clk);

        // Maintain for multiple cycles to simulate stream moving through array
        repeat(15) @(posedge clk);
	$display("Time: %0t |input(5,1) fifoOut_valid: %b | fifoOut_data: %b",
                 $time, fifoOut_axim_tvalid, fifoOut_axim_tdata);

        // Next input wavefront (4, 1)
        fifoIn_axis_tdata = 32'b00000001000001000000000100000100;
	fifoIn_axis_tvalid = 1;

        repeat(10) @(posedge clk);

	 $display("Time: %0t |input(4,1) fifoOut_valid: %b | fifoOut_data: %b",
                 $time, fifoOut_axim_tvalid, fifoOut_axim_tdata);

        // Next one (3, 1)
        fifoIn_axis_tdata = 32'b00000001000001000000000100000011;
	fifoIn_axis_tvalid = 1;
        repeat(10) @(posedge clk);

	$display("Time: %0t |input(3,1) fifoOut_valid: %b | fifoOut_data: %b",
                 $time, fifoOut_axim_tvalid, fifoOut_axim_tdata);

        // Stop sending after filling systolic array
        fifoIn_axis_tvalid = 0;
       // fifoIn_axis_tdata = 0;
       

       // Step 4: Let systolic array flush its pipeline
        repeat(150) @(posedge clk);

        // Observe results
        $display("\n---End of  Simulation ---");
        $display("Time: %0t | fifoOut_valid: %b | fifoOut_data: %b",
                 $time, fifoOut_axim_tvalid, fifoOut_axim_tdata);

       
       /*
        fifoIn_axis_tdata = 32'b00000001000001000000000100000101;
	fifoIn_axis_tvalid = 1;
        repeat(2) @(posedge clk);
        wait(fifoIn_axis_tready);
	@(posedge clk);

        // Feed data to PE array
       // fifoOut_axim_tready = 1; // ready to accept output
        repeat(150) @(posedge clk);
	fifoOut_axim_tready = 1; // ready to accept output
	@(posedge clk);
	$display("Time: %0t | fifoOut_valid: %b | fifoOut_data: %b",
                 $time, fifoOut_axim_tvalid, fifoOut_axim_tdata);

       */
        // Finish simulation after some delay
        #1000;
        $finish;
    end

            
endmodule

