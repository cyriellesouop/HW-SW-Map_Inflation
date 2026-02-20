`timescale 1ns/1ps

module tb_top2;

    // Parameters matching the top module
    parameter KERNEL_SIZE  = 5;
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
    
    initial begin
       /*
       01 02 03 04 05           26 27 28 29 30    0590 0605 0620 0635 0650
       06 07 08 09 10      *    31 32 33 34 35 =  1490 1530 1570 1610 1650
       11 12 13 14 15           36 37 38 39 40    2390 2455 2520 2585 2650 
       16 17 18 19 20           41 42 43 44 45    3290 3380 3470 3560 3650
       21 22 23 24 25           46 47 48 49 50    4190 4305 4420 4535 4650
       
       
       1 2 3 10       10 11 12 20     314 , 330, 346   388   
       4 5 6 11   *   13 14 15 21   = 454 , 480, 506   603      
       7 8 9 12       16 17 18 22     594 , 630, 666   818
       20 21 22 23    23 24 25 26    1354  1440 1526  1923  
       
       
       
       1 2 3     10 11 12     84 , 90, 96        dataOut(0,0) = 84 , dataOut(0,1)(1,0) = 90__201  dataOut(0,2)(1,1)(2,0) = 96__216__318
       4 5 6  *  13 14 15   = 201 , 216, 231      dataOut(.,.)(1,2)(2,1) = xx_  , dataOut(0,1)(1,0) =   dataOut(0,2)(1,1)(2,0) = 
       7 8 9     16 17 18     318 , 342, 366
       */
       
       rstn = 0;
       s_axis_tdata = 0;
       s_axis_tvalid = 0;
      
       
       repeat(5) @(posedge clk);
       rstn = 1;
       repeat(2) @(posedge clk);
       m_axis_tready = 1;
       @(posedge clk);
       
       //weigth load
      // s_axis_tdata = 32'b00000001_00000010_00000011_00000100;   // first transfer weights : 1,2,3,4 
      // s_axis_tdata  = 32'h01_02_03_04; 3*3
       s_axis_tdata  = 32'h01_02_03_04; 
       s_axis_tvalid = 1'b1;  
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       //weigth load;
      // s_axis_tdata = 32'b00000101_00000100_00000111_00001000;    // second transfer weights : 5,6,7,8 
      // s_axis_tdata  = 32'h05_06_07_08; 3*3
       s_axis_tdata  = 32'h05_06_07_08;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       //weigth = 32'h789;
       //s_axis_tdata = 32'b00000000_00000000_00000000_00001001;   // third transfer weights :  9
       //s_axis_tdata  = 32'h09_00_00_00;
       s_axis_tdata  = 32'h09_0a_0b_0c;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h0d_0e_0f_10;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h11_12_13_14;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
        s_axis_tdata  = 32'h15_16_17_18;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h19_00_00_00;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
        /*s_axis_tdata  = 32'h19_00_00_00;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;*/
      

       
       //repeat(2) @(posedge clk); // Gap between weights and data
      /* repeat(3) @(posedge clk);
      s_axis_tdata  = 32'h00_00_00_00;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk); */
       
       // send data   
      
       s_axis_tdata  = 32'h1A_1F_24_29;   //  first row data
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);  
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h2E_1B_20_25;   //  first row data
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);  
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
     
       s_axis_tdata  = 32'h2A_2F_1C_21; // 11,14,17 second row data
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       //s_axis_tdata = 32'b00000000_00000000_00000000_00010010;   // 18 third data transfer
       s_axis_tdata  = 32'h26_2B_30_1D;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h22_27_2C_31;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h1E_23_28_2D;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h32_00_00_00;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
  
       #10000;
        
        $finish;
       
    end
    
   always @(posedge clk) begin
        if (m_axis_tvalid && m_axis_tready) begin
            $display("Time=%0t | Output Handshake! Result=%d (decimal:%0d)", $time, m_axis_tdata, m_axis_tdata);
        end
    end 
    
    
    
    endmodule
    
   
