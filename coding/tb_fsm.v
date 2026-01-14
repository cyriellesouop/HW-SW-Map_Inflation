`timescale 1ns/1ps

module tb_fsm;

  //parameter
  parameter PERIOD = 4;
  // Inputs
  reg clk= 0 ;
  reg rstn;
  reg load_weight_en;
  reg load_weight_done;
  reg load_data_exec_done;
  reg adder_done;
  reg write_output_done;
  reg is_last;

  // Output
  wire adder_en;

  // Instantiate the DUT 
  fsm DUT (
    .clk(clk),
    .rstn(rstn),
    .load_weight_en(load_weight_en),
    .load_weight_done(load_weight_done),
    .load_data_exec_done(load_data_exec_done),
    .adder_en(adder_en),
    .adder_done(adder_done),
    .write_output_done(write_output_done),
    .is_last(is_last)
  );

  always #(PERIOD/2) clk = ~clk;
  

  
  initial begin
    rstn = 0;
    load_weight_en = 0;
    load_weight_done = 0;
    load_data_exec_done = 0;
    adder_done = 0;
    write_output_done = 0;
    is_last = 0;

    repeat(4)@(posedge clk);
    rstn = 1; 
    repeat(2)@(posedge clk);
    load_weight_en = 1;
    @(posedge clk);
    load_weight_en = 0;

    // Simulate weight load complete
    @(posedge clk);
    load_weight_done = 1;
    @(posedge clk);
    load_weight_done = 0;

    // Simulate data execution done
    @(posedge clk);
    load_data_exec_done = 1;
    @(posedge clk);
    load_data_exec_done = 0;

    // Simulate adder done
    @(posedge clk);
    adder_done = 1;
    @(posedge clk);
    adder_done = 0;

    // Simulate write output done
    @(posedge clk);
    write_output_done = 1;
    @(posedge clk);
    write_output_done = 0;

    // 1st iteration: not last
    @(posedge clk);
    is_last = 0;

    // repeat data/adder/write
    @(posedge clk);
    load_data_exec_done = 1;
    @(posedge clk);
    load_data_exec_done = 0;

    @(posedge clk);
    adder_done = 1;
    @(posedge clk);
    adder_done = 0;

    @(posedge clk);
    write_output_done = 1;
    @(posedge clk);
    write_output_done = 0;

    // is_last=1
    repeat(2) @(posedge clk);
    is_last = 1;

    @(posedge clk);
    load_data_exec_done <= 1;
    @(posedge clk);
    load_data_exec_done <= 0;

    // Trigger last adder and write
    @(posedge clk);
    adder_done <= 1;
    @(posedge clk);
    adder_done <= 0;

    @(posedge clk);
    write_output_done <= 1;
    @(posedge clk);
    write_output_done <= 0;


    #40;
    $finish;
  end

  // Monitor
  initial begin
    $monitor("[%0t] state = %0d adder_en=%b | load_weight_en=%b load_weight_done=%b load_data_exec_done=%b adder_done=%b write_output_done=%b is_last=%b",
             $time, DUT.state , adder_en,
             load_weight_en, load_weight_done, load_data_exec_done,
             adder_done, write_output_done, is_last);
  end

endmodule

