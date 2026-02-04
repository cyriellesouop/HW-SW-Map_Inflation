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
    localparam SUM_WIDTH      = DATA_WIDTH + WEIGHT_WIDTH + KERNEL_SIZE;
    localparam DATAOUT_WIDTH  = SUM_WIDTH * KERNEL_SIZE;
    localparam WEIGHTIN_WIDTH = WEIGHT_WIDTH * KERNEL_SIZE * KERNEL_SIZE;
    localparam NUM_WEIGHT_TRANSFERS = (WEIGHTIN_WIDTH + BUS_WIDTH - 1) / BUS_WIDTH;
    
    
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
    
    reg[31:0] weight;
    reg[31:0] data;
    // --------------Clock Generation --------------------------------
    always #(PERIOD/2) clk = ~clk;
    
    initial begin
       /*
       1 2 3     10 11 12     (1*10 + 2*13 + 3*16) , (1*11 + 2*14 + 3*17) (1*12+ 2*15 + 3*18) 
       4 5 6  *  13 14 15   = (4*10 + 5*13 + 6*16) , (4*11 + 5*14 + 6*17) (4*12+ 5*15 + 6*18) 
       7 8 9     16 17 18     (7*10 + 8*13 + 9*16) , (7*11 + 8*14 + 9*17) (7*12+ 8*15 + 9*18)
       
       1 2 3     10 11 12     84 , 90, 96         dataOut(0,0) = 84 , dataOut(0,1)(1,0) = 90__201  dataOut(0,2)(1,1)(2,0) = 96__216__318
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
       s_axis_tdata  = 32'h09_00_00_00;
       s_axis_tvalid = 1'b1;     
       @(posedge clk);
       wait(s_axis_tready);
       $display ("%0t second weights value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       
       //repeat(2) @(posedge clk); // Gap between weights and data
       repeat(4) @(posedge clk);
       
       // send data   
       //s_axis_tdata  = 32'h0a_0d_10_0b; // 10,13,16,11 first transfer data
       s_axis_tdata  = 32'h0a_0d_10_00;   // 10,13,16 first row data
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);  
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       //s_axis_tdata  = 32'h0e_11_0c_0f; // 14,17,12,15 second transfer data
       s_axis_tdata  = 32'h0b_0e_11_00; // 11,14,17 second row data
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       //s_axis_tdata = 32'b00000000_00000000_00000000_00010010;   // 18 third data transfer
       s_axis_tdata  = 32'h0c_0f_12_00;
       s_axis_tvalid = 1'b1;    
       @(posedge clk);   
       wait(s_axis_tready);
       $display ("%0t first data value is %0h", $time , s_axis_tdata);
       s_axis_tvalid = 1'b0;
       @(posedge clk);
       
       repeat(1000) begin
           @(posedge clk);
           if (m_axis_tvalid && m_axis_tready) begin
               $display("%0t | VALID OUTPUT: %b", $time, m_axis_tdata);
           end
       end
       
       #100;
        
        $finish;
       
    end
    
    endmodule
    
   
