`timescale 1ns/1ps

module tb_adder_tree;

    // Parameters
    parameter KERNEL_SIZE  = 3;
    parameter DATA_WIDTH   = 8;
    parameter WEIGHT_WIDTH = 8;
    parameter DEPTH        = 8;
    parameter PTR_WIDTH    = 3;
    parameter PRODUCT_WIDTH = DATA_WIDTH + WEIGHT_WIDTH;
    parameter OUTPUT_WIDTH  = PRODUCT_WIDTH + $clog2(KERNEL_SIZE);
    
    // Clock period
    parameter CLK_PERIOD = 4;

    // Signals
    reg  clk = 0;
    reg  rstn;
    reg  adder_en;
    reg  [(DATA_WIDTH + WEIGHT_WIDTH) * KERNEL_SIZE - 1 : 0] adder_dataIn;
    reg  m_axis_tready;
    wire [OUTPUT_WIDTH - 1 : 0] m_axis_tdata;
    wire m_axis_tvalid;

    // DUT instantiation
    adder_tree #(
        .KERNEL_SIZE  (KERNEL_SIZE),
        .DATA_WIDTH   (DATA_WIDTH),
        .WEIGHT_WIDTH (WEIGHT_WIDTH),
        .DEPTH        (DEPTH),
        .PTR_WIDTH    (PTR_WIDTH)
    ) dut (
        .clk          (clk),
        .rstn         (rstn),
        .adder_en     (adder_en),
        .adder_dataIn (adder_dataIn),
        .m_axis_tready(m_axis_tready),
        .m_axis_tdata (m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Test stimulus
    initial begin
        // Initialize
        rstn = 0;
        adder_en = 0;
        adder_dataIn = 0;
        m_axis_tready = 1;
        
        // Reset
        repeat(5) @(posedge clk);
        rstn = 1;
        @(posedge clk);
        
        // Test 1: Simple addition (1 + 2 + 3 = 6)
        adder_en = 1;
        adder_dataIn = {16'd3, 16'd2, 16'd1};
        @(posedge clk);
        
        // Test 2: Larger values (100 + 200 + 300 = 600)
        adder_dataIn = {16'd300, 16'd200, 16'd100};
        @(posedge clk);
        
        // Test 3: Disable adder_en
        adder_en = 0;
        repeat(2)@(posedge clk);
        
        // Test 4: Backpressure test - downstream not ready
        adder_en = 1;
        adder_dataIn = {16'd50, 16'd60, 16'd70};
        @(posedge clk);
        m_axis_tready = 0;  // Block downstream
        repeat(3) @(posedge clk);
        
        
        // Test 5: Continuous data stream
        repeat(10) begin
            adder_dataIn = {($random % 10) & 16'hFFFF,($random % 10) & 16'hFFFF,($random % 10) & 16'hFFFF};
            //adder_dataIn = {16'd($random % 10), 16'd($random % 10), 16'd($random % 10)};
            @(posedge clk);
        end
        m_axis_tready = 1;  // Release
        adder_en = 1;
        repeat(20) @(posedge clk);
        
        $display("Test completed!");
        $finish;
    end

    // Monitor output
    always @(posedge clk) begin
        if (m_axis_tvalid && m_axis_tready) begin
            $display("Time=%0t: Output = %0d", $time, m_axis_tdata);
        end
    end

endmodule
