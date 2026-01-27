`timescale 1ns/1ps

module tb_top_fifo;

    // Parameters
    parameter KERNEL_SIZE = 3;
    parameter DATA_WIDTH   = 8;
    parameter FIFO_DEPTH  = 4;
    localparam FULL_WIDTH = KERNEL_SIZE * DATA_WIDTH;
    localparam PERIOD = 4;

    // Signals
    reg clk = 0;
    reg rstn;
    
    // Slave Interface (Input to Splitter)
    reg [FULL_WIDTH-1:0] s_axis_tdata;
    reg                  s_axis_tvalid;
    wire                 s_axis_tready;

    // Master Interface (Output from Splitter)
    reg  [KERNEL_SIZE-1:0] m_axis_tready;
    wire [FULL_WIDTH-1:0]  m_axis_tdata;
    wire [KERNEL_SIZE-1:0] m_axis_tvalid;

    // Clock Generation
    always #(PERIOD/2) clk = ~clk;

    // Instantiate the Top System
    top_fifo #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),

        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),

        .m_axis_tready(m_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid)
    );

    // --- Task: Push Data ---
    task axis_push(input [FULL_WIDTH-1:0] data);
        begin
            s_axis_tvalid <= 1'b1;
            s_axis_tdata  <= data;
            wait(s_axis_tready)
	    @(posedge clk); 
            s_axis_tvalid <= 1'b0;
        end
    endtask

    // --- Test Sequence ---
    initial begin
        // Reset
        rstn = 0;
        s_axis_tvalid = 0;
        s_axis_tdata = 0;
        m_axis_tready = 0;
        repeat(2) @(posedge clk);
       	rstn = 1;
        repeat(2) @(posedge clk);

        // 1. Fill the FIFOs until full :  We push FIFO_DEPTH items to fill it
        axis_push(24'hAA_BB_CC); // Data 0: F2=AA, F1=BB, F0=CC
        axis_push(24'h11_22_33); // Data 1: F2=11, F1=22, F0=33
        axis_push(24'hDD_EE_FF); // Data 2: F2=DD, F1=EE, F0=FF
        axis_push(24'h44_55_66); // Data 3: F2=44, F1=55, F0=66
	
	@(posedge clk);

	// 2. The 5th item attempt
        $display("%0t: Attempting 5th push. s_axis_tready = %b and m_axis_tready = %b", $time, s_axis_tready, m_axis_tready);
        s_axis_tvalid <= 1'b1;
        s_axis_tdata  <= 24'h77_88_99;

	repeat(3) @(posedge clk); // To see that the 5th item is stuck on the waveform
	
        // 3. Read one item to make space in the FIFOs
        m_axis_tready <= 3'b111; 
        @(posedge clk);
        m_axis_tready <= 3'b000;
	@(posedge clk);
	$display("%0t item read is  m_axis_tdata= %0h ", $time, m_axis_tdata);

	// 4. Finish the 5th transfer
        wait(s_axis_tready);
        @(posedge clk);
        s_axis_tvalid <= 1'b0;
	@(posedge clk);
        $display("%0t: Item 5 successfully entered the FIFO. s_axis_tready = %b", $time, s_axis_tready  );

        // 5. Empty everything
        repeat(5) @(posedge clk);
        m_axis_tready <= 3'b111;
        wait(m_axis_tvalid == 3'b000);
        $display("%0t  All FIFOs empty .  Last data read is :  m_axis_tdata= %0h ", $time, m_axis_tdata);

        #100 $finish;
    end

endmodule
