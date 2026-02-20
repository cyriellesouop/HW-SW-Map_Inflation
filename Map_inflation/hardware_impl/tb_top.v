`timescale 1ns/1ps

module tb_top2;

    // Parameters matching the top module
    parameter KERNEL_SIZE  = 3;
    parameter DATA_WIDTH   = 8;
    parameter WEIGHT_WIDTH = 8;
    parameter DEPTH        = 8;
    parameter PTR_WIDTH    = 3;
    parameter BUS_WIDTH    = 32;
    
    localparam PERIOD = 4; //250 MHZ
    // Calculated parameters
    localparam SUM_WIDTH      = DATA_WIDTH + WEIGHT_WIDTH + $clog2(KERNEL_SIZE);
    localparam DATAOUT_WIDTH  = SUM_WIDTH ;
    localparam WEIGHTIN_WIDTH = WEIGHT_WIDTH * KERNEL_SIZE * KERNEL_SIZE;
   // localparam NUM_WEIGHT_TRANSFERS = (WEIGHTIN_WIDTH + BUS_WIDTH - 1) / BUS_WIDTH;
    
    
    reg clk=0;
    reg rstn;
    
    // Input
    reg  [BUS_WIDTH-1:0]     s_axis_tdata;
    reg                      s_axis_tvalid;
    wire                     s_axis_tready;
    
    // Output
    reg                      m_axis_tready;
    wire [DATAOUT_WIDTH-1:0] m_axis_tdata;
    wire                     m_axis_tvalid;
    
    // DUT
    top #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .DEPTH(DEPTH),
        .PTR_WIDTH(PTR_WIDTH),
        .BUS_WIDTH(BUS_WIDTH)
    ) DUT (
        .clk(clk),
        .rstn(rstn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .m_axis_tready(m_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid)
    );
    
    reg[31:0] weight;
    reg[31:0] data;
   
    // --------------Clock Generation --------------------------------
    always #(PERIOD/2) clk = ~clk;
    
    
       /*
       1 2 3 10       10 11 12 20     (1*10 + 2*13 + 3*16 + 10*23) , (1*11 + 2*14 + 3*17 + 10*24) , (1*12+ 2*15 + 3*18 + 10*25) ,  (1*20+ 2*21 + 3*22 + 10*26)
       4 5 6 11   *   13 14 15 21  =  (4*10 + 5*13 + 6*16 + 11*23) , (4*11 + 5*14 + 6*17 + 11*24) (4*12+ 5*15 + 6*18 + 11*25) (4*20+ 5*21 + 6*22 + 11*26)
       7 8 9 12       16 17 18 22     (7*10 + 8*13 + 9*16 + 12*23) , (7*11 + 8*14 + 9*17 + 12*24 ) (7*12+ 8*15 + 9*18 + 12*25) ( 7*20+ 8*21 + 9*22 + 12*26 )
       20 21 22 23    23 24 25 26      (20*10 + 21*13 + 22*16 + 23*23) , (20*11 + 21*14 + 22*17 + 23*24 ) (20*12+ 21*15 + 22*18 + 23*25) ( 20*20+ 21*21 + 22*22 + 23*26 )
       
       1 2 3 10       10 11 12 20     314 , 330, 346   388   
       4 5 6 11   *   13 14 15 21   = 454 , 480, 506   603      
       7 8 9 12       16 17 18 22     594 , 630, 666   818
       20 21 22 23    23 24 25 26    1354  1440 1526  1923  
       
       
       
       1 2 3     10 11 12     84 , 90, 96        dataOut(0,0) = 84 , dataOut(0,1)(1,0) = 90__201  dataOut(0,2)(1,1)(2,0) = 96__216__318
       4 5 6  *  13 14 15   = 201 , 216, 231      dataOut(.,.)(1,2)(2,1) = xx_  , dataOut(0,1)(1,0) =   dataOut(0,2)(1,1)(2,0) = 
       7 8 9     16 17 18     318 , 342, 366
       */
    task automatic send_word(input [BUS_WIDTH-1:0] w);
    begin
        s_axis_tdata  <= w;
        s_axis_tvalid <= 1'b1;

        // wait until a real handshake can occur
        while (!s_axis_tready)
            @(posedge clk);

        // handshake happens on this edge
        @(posedge clk);
    end
    endtask

    // ------------------------------------------------------------
    // Stimulus
    // ------------------------------------------------------------
    initial begin

        rstn           = 0;
        s_axis_tdata   = 0;
        s_axis_tvalid  = 0;
        m_axis_tready  = 0;

        repeat(5) @(posedge clk);
        rstn = 1;

        repeat(3) @(posedge clk);
        m_axis_tready = 1;
        @(posedge clk);

        // ----------------------------
        // WEIGHTS (back-to-back)
        // ----------------------------
        send_word(32'h01_02_03_04);   // 1 2 3 4
        send_word(32'h05_06_07_08);   // 5 6 7 8
        send_word(32'h09_00_00_00);   // 9

        // stop driving for a moment (optional)
        s_axis_tvalid <= 1'b0;

        // small gap between weight phase and data phase
        repeat(2) @(posedge clk);

        // ----------------------------
        // DATA (back-to-back)
        // ----------------------------
        send_word(32'h0a_0d_10_0b);   // 10,13,16,11
        send_word(32'h0e_11_0c_0f);   // 14,17,12,15
        send_word(32'h12_00_00_00);   // 18

        s_axis_tvalid <= 1'b0;

        #6000;
        $finish;
    end

    // ------------------------------------------------------------
    // Output monitor
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (m_axis_tvalid && m_axis_tready) begin
            $display("Time=%0t | Output handshake | Result=%0d",
                      $time, m_axis_tdata);
        end
    end

endmodule
