`timescale 1ns/1ps

module tb_crossbar;

    // Parameters
    parameter KERNEL_SIZE = 3;
    parameter DATA_WIDTH  = 18;
    parameter PERIOD  = 4;

    // DUT signals
    reg clk = 0;
    reg rstn;
    
    reg  [KERNEL_SIZE-1:0] s_axis_tvalid;
    reg  [DATA_WIDTH*KERNEL_SIZE-1:0] s_axis_tdata;
    wire [KERNEL_SIZE-1:0] s_axis_tready;
    
    wire m_axis_tvalid;
    wire [DATA_WIDTH-1:0] m_axis_tdata;
    reg  m_axis_tready;

    integer i;
    integer transaction_count;

    // DUT Instantiation
    crossbar #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    )  DUT (
        .clk(clk),
        .rstn(rstn),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tready(s_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tready(m_axis_tready)
    );

    // Clock generation
    always  #(PERIOD/2) clk = ~clk;

    // Test stimulus
    initial begin
        
        // Initialize
        rstn = 0;
        s_axis_tvalid = 3'b000;
        s_axis_tdata = 0;
        m_axis_tready = 0;
        
        // Reset
        repeat(5) @(posedge clk);
        rstn = 1;
        repeat(3) @(posedge clk);
        
        // Scenario 1: Basic operation - all slaves send data
        $display("\n %0t Scenario 1: Basic Round-Robin ", $time);
        
        @(posedge clk);
        s_axis_tvalid = 3'b111;
        s_axis_tdata[0*DATA_WIDTH +: DATA_WIDTH] = 18'h10001;  // Slave 0
        s_axis_tdata[1*DATA_WIDTH +: DATA_WIDTH] = 18'h20001;  // Slave 1
        s_axis_tdata[2*DATA_WIDTH +: DATA_WIDTH] = 18'h30001;  // Slave 2
        
        @(posedge clk);
        s_axis_tvalid = 3'b000;
        
        repeat(5) @(posedge clk);
        
        // Master reads the data
        m_axis_tready = 1;
        repeat(15) @(posedge clk);
        m_axis_tready = 0;
        
        repeat(5) @(posedge clk);
        
        // Scenario 2: Master applies backpressure
        $display("\n %0t Scenario 2: Master Backpressure ", $time);
        
        @(posedge clk);
        s_axis_tvalid = 3'b111;
        s_axis_tdata[0*DATA_WIDTH +: DATA_WIDTH] = 18'h10002;
        s_axis_tdata[1*DATA_WIDTH +: DATA_WIDTH] = 18'h20002;
        s_axis_tdata[2*DATA_WIDTH +: DATA_WIDTH] = 18'h30002;
        
        @(posedge clk);
        s_axis_tvalid = 3'b000;
        
        repeat(3) @(posedge clk);
        
        // Master toggles ready
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            m_axis_tready = ~m_axis_tready;
        end
        
        m_axis_tready = 1;
        repeat(10) @(posedge clk);
        m_axis_tready = 0;
        
        repeat(5) @(posedge clk);
        
        // Scenario 3: Only 2 slaves have data (startup test)
        $display("\n %0t Scenario 3: Not All Slaves Ready ", $time);
        
        // Reset the module
        rstn = 0;
        repeat(3) @(posedge clk);
        rstn = 1;
        repeat(2) @(posedge clk);
        
        // Only slaves 0 and 1 send data
        @(posedge clk);
        s_axis_tvalid = 3'b011;
        s_axis_tdata[0*DATA_WIDTH +: DATA_WIDTH] = 18'h10003;
        s_axis_tdata[1*DATA_WIDTH +: DATA_WIDTH] = 18'h20003;
        
        @(posedge clk);
        s_axis_tvalid = 3'b000;
        
        m_axis_tready = 1;
        repeat(10) @(posedge clk);  // Master should NOT output yet
        
        // Now slave 2 sends data
        @(posedge clk);
        s_axis_tvalid = 3'b100;
        s_axis_tdata[2*DATA_WIDTH +: DATA_WIDTH] = 18'h30003;
        
        @(posedge clk);
        s_axis_tvalid = 3'b000;
        
        repeat(15) @(posedge clk);  // Now master should output
        m_axis_tready = 0;
        
        repeat(5) @(posedge clk);
        
        // Scenario 4: One slave stops sending (round-robin order test)
        $display("\n %0t Scenario 4: One Slave Stalls ", $time);
        
        m_axis_tready = 1;
        
        // Send data from slaves 0 and 2, skip slave 1
        @(posedge clk);
        s_axis_tvalid = 3'b101;
        s_axis_tdata[0*DATA_WIDTH +: DATA_WIDTH] = 18'h10004;
        s_axis_tdata[2*DATA_WIDTH +: DATA_WIDTH] = 18'h30004;
        
        @(posedge clk);
        s_axis_tvalid = 3'b000;
        
        repeat(10) @(posedge clk);  // Should output slave 0, then wait for slave 1
        
        // Now send from slave 1
        @(posedge clk);
        s_axis_tvalid = 3'b010;
        s_axis_tdata[1*DATA_WIDTH +: DATA_WIDTH] = 18'h20004;
        
        @(posedge clk);
        s_axis_tvalid = 3'b000;
        
        repeat(10) @(posedge clk);
        m_axis_tready = 0;
        
        repeat(5) @(posedge clk);
        
        // Scenario 5: Continuous data stream
        $display("\n %0t Scenario 5: Continuous Stream ", $time);
        
        m_axis_tready = 1;
        
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            s_axis_tvalid = 3'b111;
            s_axis_tdata[0*DATA_WIDTH +: DATA_WIDTH] = 18'h10000 + i;
            s_axis_tdata[1*DATA_WIDTH +: DATA_WIDTH] = 18'h20000 + i;
            s_axis_tdata[2*DATA_WIDTH +: DATA_WIDTH] = 18'h30000 + i;
        end
        
        @(posedge clk);
        s_axis_tvalid = 3'b000;
        
        repeat(40) @(posedge clk);
        m_axis_tready = 0;
        
        repeat(5) @(posedge clk);
        
        // Scenario 6: Random ready/valid patterns
        $display("\n %0t Scenario 6: Random Patterns", $time);
        
        for (i = 0; i < 30; i = i + 1) begin
            @(posedge clk);
            s_axis_tvalid = $random & 3'b111;
            s_axis_tdata[0*DATA_WIDTH +: DATA_WIDTH] = $random & 18'h3FFFF;
            s_axis_tdata[1*DATA_WIDTH +: DATA_WIDTH] = $random & 18'h3FFFF;
            s_axis_tdata[2*DATA_WIDTH +: DATA_WIDTH] = $random & 18'h3FFFF;
            m_axis_tready = $random;
        end
        
        s_axis_tvalid = 3'b000;
        m_axis_tready = 1;
        repeat(20) @(posedge clk);
        m_axis_tready = 0;
        
        // End simulation
        repeat(10) @(posedge clk);
        
        $display("\n %0t Simulation Complete \n",$time);
        $finish;
    end

    initial begin
        #100000;
        $display(" Timeout!");
        $finish;
    end

// always block to monito input
    always @(posedge clk) begin
        if (rstn) begin
            for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
                if (s_axis_tvalid[i] && s_axis_tready[i]) begin
			$display(" \n %0t SLAVE[%0d] INPUT: Data = 0x%h", $time, i, s_axis_tdata[i*DATA_WIDTH +: DATA_WIDTH]);
                end
            end
        end
    end

    // always block to monitor output
     always @(posedge clk) begin
        if (rstn) begin
            // Monitor master output transactions
            if (m_axis_tvalid && m_axis_tready) begin
                $display("%0t master output data : Data = 0x%h ( %0d )", $time, m_axis_tdata, m_axis_tdata);
                transaction_count = transaction_count + 1;
            end

            // Monitor when master is valid but stalled
            if (m_axis_tvalid && !m_axis_tready) begin
                $display("%0t  master is valid but  STALLED: Data = 0x%h (waiting for ready)", $time, m_axis_tdata);
            end
        end
    end

endmodule
