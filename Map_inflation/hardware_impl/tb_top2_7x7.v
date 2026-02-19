`timescale 1ns/1ps

module tb_top2;

    // Parameters matching the top module
    parameter KERNEL_SIZE  = 7;
    parameter DATA_WIDTH   = 8;
    parameter WEIGHT_WIDTH = 8;
    parameter DEPTH        = 10;
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
       
       01 02 03 04 05 06 07        50 51 52 53 54 55 56          2184 & 2212 & 2240 & 2268 & 2296 & 2324 & 2352
       08 09 10 11 12 13 14        57 58 59 60 61 62 63          5663 & 5740 & 5817 & 5894 & 5971 & 6048 & 6125
       15 16 17 18 19 20 21        64 65 66 67 68 69 70          9142 & 9268 & 9394 & 9520 & 9646 & 9772 & 9898  
       22 23 24 25 26 27 28   *    71 72 73 74 75 76 77    =     12621 & 12796 & 12971 & 13146 & 13321 & 13496 & 13671
       29 30 31 32 33 34 35        78 79 80 81 82 83 84          16100 & 16324 & 16548 & 16772 & 16996 & 17220 & 17444
       36 37 38 39 40 41 42        85 86 87 88 89 90 91          19579 & 19852 & 20125 & 20398 & 20671 & 20944 & 21217 
       43 44 45 46 47 48 49        92 93 94 95 96 97 98          23058 & 23380 & 23702 & 24024 & 24346 & 24668 & 24990
       
  1512    1708    1904    2100    2296    2492    2688
  4109    4648    5187    5726    6265    6804    7343
  6706    7588    8470    9352   10234   11116   11998  (this is the actual correct testbench output due to the way that I sent atas.
  9303   10528   11753   12978   14203   15428   16653
 11900   13468   15036   16604   18172   19740   21308
 14497   16408   18319   20230   22141   24052   25963
 17094   19348   21602   23856   26110   28364   30618
       
       
       
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
       s_axis_tdata  = 32'h01_02_03_04;
       s_axis_tvalid = 1'b1;  
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       //weigth load;
      // s_axis_tdata = 32'b00000101_00000100_00000111_00001000;    // second transfer weights : 5,6,7,8 
       s_axis_tdata  = 32'h05_06_07_08;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       //weigth = 32'h789;
       //s_axis_tdata = 32'b00000000_00000000_00000000_00001001;   // third transfer weights :  9
       s_axis_tdata  = 32'h09_0a_0b_0c;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
         //s_axis_tdata = 32'b00000000_00000000_00000000_00001001;   // third transfer weights :  9
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
       
       s_axis_tdata  = 32'h19_1A_1B_1C;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h1d_1e_1f_20;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h21_22_23_24;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       
       s_axis_tdata  = 32'h25_26_27_28;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h29_2a_2b_2c;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       
       s_axis_tdata  = 32'h2d_2e_2f_30;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
        s_axis_tdata  = 32'h31_00_00_00;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       //repeat(2) @(posedge clk); // Gap between weights and data
       repeat(4) @(posedge clk);
       
       // send data   
       //s_axis_tdata  = 32'h0a_0d_10_0b; // 10,13,16,11 first transfer data
       s_axis_tdata  = 32'h32_33_34_35;   // 10,13,16 first row data
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);  
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       //s_axis_tdata  = 32'h0e_11_0c_0f; // 14,17,12,15 second transfer data
       s_axis_tdata  = 32'h36_37_38_39; // 11,14,17 second row data
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       //s_axis_tdata = 32'b00000000_00000000_00000000_00010010;   // 18 third data transfer
       s_axis_tdata  = 32'h3a_3b_3c_3d;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       //s_axis_tdata = 32'b00000000_00000000_00000000_00010010;   // 18 third data transfer
       s_axis_tdata  = 32'h3e_3f_40_41;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h42_43_44_45;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h46_47_48_49;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h4a_4b_4c_4d;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h4e_4f_50_51;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h52_53_54_55;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h56_57_58_59;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h5a_5b_5c_5d;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h5e_5f_60_61;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       s_axis_tdata  = 32'h62_00_00_00;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       

       #6000;
        
        $finish;
       
    end
    
   always @(posedge clk) begin
        if (m_axis_tvalid && m_axis_tready) begin
            $display("Time=%0t | Output Handshake! Result=%d (decimal:%0d)", $time, m_axis_tdata, m_axis_tdata);
        end
    end 
    
    
    
    endmodule
    
   
