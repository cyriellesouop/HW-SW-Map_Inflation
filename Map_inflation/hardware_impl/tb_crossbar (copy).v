`timescale 1ns/1ps

module tb_crossbar;

    // Parameters
    parameter KERNEL_SIZE = 3;
    parameter DATA_WIDTH  = 18;
    parameter PERIOD  = 4;

    // Signals
    reg  clk=0;
    reg  rstn;
    reg  [KERNEL_SIZE-1:0] s_axis_tvalid;
    reg  [DATA_WIDTH*KERNEL_SIZE-1:0] s_axis_tdata;
    wire [KERNEL_SIZE-1:0] s_axis_tready;
    wire m_axis_tvalid;
    wire [DATA_WIDTH-1:0] m_axis_tdata;
    reg  m_axis_tready;

    // Helper array for easier data manipulation
    reg [DATA_WIDTH-1:0] test_data [0:KERNEL_SIZE-1];
    integer i;

    // DUT instantiation
    crossbar #(
        .KERNEL_SIZE (KERNEL_SIZE),
        .DATA_WIDTH  (DATA_WIDTH)
    ) dut (
        .clk          (clk),
        .rstn         (rstn),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tdata (s_axis_tdata),
        .s_axis_tready(s_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tdata (m_axis_tdata),
        .m_axis_tready(m_axis_tready)
    );

    // Pack test_data array into flat bus
    always @(*) begin
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
            s_axis_tdata[i*DATA_WIDTH +: DATA_WIDTH] = test_data[i];
        end
    end

    // Clock generation
    always #(PERIOD/2) clk = ~clk;

    // Test stimulus
    initial begin
        // Initialize
        rstn = 0;
        s_axis_tvalid = 0;
        test_data[0] = 0;
        test_data[1] = 0;
        test_data[2] = 0;
        m_axis_tready = 0;
        
        // Reset
        repeat(5) @(posedge clk);
        rstn = 1;
        @(posedge clk);

	m_axis_tready = 1;
	@(posedge clk);

        
        $display("\n %0t === Test 1: All channels valid " , $time);
        s_axis_tvalid = 3'b111;
        test_data[0] = 18'd100;
        test_data[1] = 18'd200;
        test_data[2] = 18'd300;
        repeat(6) @(posedge clk);  
        
        $display("\n %0t === Test 2: Only channel 1 valid (others empty) " , $time);
        s_axis_tvalid = 3'b010;
        test_data[0] = 18'd111;
        test_data[1] = 18'd222;
        test_data[2] = 18'd333;
        repeat(6) @(posedge clk);  // Should skip empty channels rapidly
        
        $display("\n %0t === Test 3: Backpressure - master not ready ", $time);
	m_axis_tready = 0; //Block downstream
	@(posedge clk);
        s_axis_tvalid = 3'b111;
        test_data[0] = 18'd10;
        test_data[1] = 18'd20;
        test_data[2] = 18'd30;
        repeat(5) @(posedge clk);  // Counter should freeze
        m_axis_tready = 1;  // Release
        repeat(5) @(posedge clk);
        
        $display("\n %0t === Test 4: Only channels 0 and 2 valid signals", $time);
        s_axis_tvalid = 3'b101;  // Only channels 0 and 2
        test_data[0] = 18'd55;
        test_data[1] = 18'd66;  // Won't be output
        test_data[2] = 18'd77;
        repeat(6) @(posedge clk);
        
        $display("\n %0t === Test 5: Dynamic valid changes === ", $time);
        s_axis_tvalid = 3'b111;
        test_data[0] = 18'd1000;
        test_data[1] = 18'd2000;
        test_data[2] = 18'd3000;
        @(posedge clk);
        @(posedge clk);
        s_axis_tvalid = 3'b001;  // Only channel 0 now
        test_data[0] = 18'd1111;
        repeat(6) @(posedge clk);
        
        $display("\n %0t === Test 6: All channels invalid === ", $time);
        s_axis_tvalid = 3'b000;
        repeat(5) @(posedge clk);  // Should cycle but output invalid
        
     /*   $display("\n %0t === Test 7: Intermittent backpressure === ", $time);
        s_axis_tvalid = 3'b111;
        test_data[0] = 18'd400;
        test_data[1] = 18'd500;
        test_data[2] = 18'd600;
	@(posedge clk);
        for (i = 0; i < 10; i = i + 1) begin
            m_axis_tready = (i % 3 != 0);  // Ready, Ready, NotReady pattern
            @(posedge clk);
        end
        m_axis_tready = 1;
       */ 
        repeat(10) @(posedge clk);
        $display("\n %0t Test completed! ", $time);
        $finish;
    end

    // Monitor outputs
    always @(posedge clk) begin
        if (rstn) begin
            $display(" %0t | Count=%0d | s_valid=%b | s_ready=%b | m_valid=%b | m_ready=%b | m_data=%0d", 
                     $time, dut.count, s_axis_tvalid, s_axis_tready, 
                     m_axis_tvalid, m_axis_tready, m_axis_tdata);
        end
    end

    // Check for successful transfers
    always @(posedge clk) begin
        if (rstn && m_axis_tvalid && m_axis_tready) begin
            $display("%0t TRANSFER: Channel %0d transferred data = %0d", $time, dut.count, m_axis_tdata);
        end
    end

endmodule
