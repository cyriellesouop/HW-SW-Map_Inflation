`timescale 1ns/1ps

module top
   #(
      parameter WEIGHT_WIDTH = 1,
      parameter DATA_WIDTH   = 8,
      parameter KERNEL_SIZE  = 3,
      parameter ADDRESS_WIDTH = 5
   )
   (
      input clk,
      input rstn,
      //weights input
      input [(WEIGHT_WIDTH*KERNEL_SIZE*KERNEL_SIZE)-1:0] weight_array,
      input wr_weight_en,

      //slave input fifo
      input fifoIn_axis_tvalid,
      input [(DATA_WIDTH*KERNEL_SIZE*KERNEL_SIZE)-1:0] fifoIn_axis_tdata,
      output   fifoIn_axis_tready,

      // master output fifo
      output  fifoOut_axim_tvalid,
      output  [(DATA_WIDTH+WEIGHT_WIDTH)+KERNEL_SIZE-1:0] fifoOut_axim_tdata,
      input fifoOut_axim_tready,

      //input to stop the systolic array
      input is_last
    );

    // output data from the input fifo    
    wire [(DATA_WIDTH*KERNEL_SIZE*KERNEL_SIZE)-1:0] fifoIn_axim_tdata;
    wire fifoIn_axim_tvalid;
   // wire is_last  //to double check again

    // signals to the systolic arrays
    wire [(DATA_WIDTH*KERNEL_SIZE*KERNEL_SIZE)-1:0] pe_array_dataIn;
    wire pe_array_wr_dataIn_en;
    wire wr_weight_done;
    wire pe_array_done;
    wire [(DATA_WIDTH+WEIGHT_WIDTH)*KERNEL_SIZE-1:0] pe_array_dataOut;

    //adder tree signals
    wire [(DATA_WIDTH+WEIGHT_WIDTH)+KERNEL_SIZE-1:0] adder_dataOut;
    wire adder_done;

    //fifo out signals
    wire fifoOut_axis_tready;

    //fsm signals
    wire fsm_adder_en;

    assign pe_array_dataIn = fifoIn_axim_tdata;
    assign pe_array_wr_dataIn_en = fifoIn_axim_tvalid;


    //input fifo containing the pixels slide
    fifo_axis #(
      	.DATAWIDTH ( DATA_WIDTH*KERNEL_SIZE*KERNEL_SIZE ),
	.DEPTH     (2**ADDRESS_WIDTH),
	.PTR_WIDTH (ADDRESS_WIDTH)
      )
      fifoIn(
       .clk      (clk),
       .rstn     (rstn),

       .s_tvalid (fifoIn_axis_tvalid  ),
       .s_tdata  (fifoIn_axis_tdata ),
       .s_tready (fifoIn_axis_tready ),

       .m_tready (fifoOut_axim_tready),      // adder_done : systolic array ready  when adder tree has done computation 
       .m_tdata  (fifoIn_axim_tdata),
       .m_tvalid (fifoIn_axim_tvalid)
      );


  //systolic array block
    pe_array #(
        .WEIGHT_WIDTH   (WEIGHT_WIDTH),
        .DATA_WIDTH     (DATA_WIDTH),
        .KERNEL_SIZE    (KERNEL_SIZE)
      ) 
     pe_array_inst (
        .clk            (clk),
        .rstn           (rstn),

        .weight_array   (weight_array),
        .wr_weight_en   (wr_weight_en),
        .dataIn         (pe_array_dataIn),
	.wr_dataIn_en   (pe_array_wr_dataIn_en),

        .wr_weight_done (wr_weight_done ),
        .pe_array_done  (pe_array_done),
        .dataOut        (pe_array_dataOut)
     );

  //adder tree
  adder_tree #(
  	.WEIGHT_WIDTH  (WEIGHT_WIDTH),
        .DATA_WIDTH    (DATA_WIDTH),
        .KERNEL_SIZE   (KERNEL_SIZE)
      ) 
     adder_tree_inst (
	.clk           (clk),
        .rstn          (rstn),

	.adder_en      (fsm_adder_en),
	.adder_dataIn  (pe_array_dataOut),

	.adder_dataOut (adder_dataOut),
	.adder_done    (adder_done)
      );

  // Output fifo containing the output result of the systolic block
     fifo_axis #(
        .DATAWIDTH ((DATA_WIDTH+WEIGHT_WIDTH)+KERNEL_SIZE),
        .DEPTH     (2**ADDRESS_WIDTH),
        .PTR_WIDTH (ADDRESS_WIDTH)
      )
      fifoOut(
       .clk        (clk),
       .rstn       (rstn),

       .s_tvalid   (adder_done),
       .s_tdata    (adder_dataOut ),
       .s_tready   (fifoOut_axis_tready),

       .m_tready   (fifoOut_axim_tready),
       .m_tdata    (fifoOut_axim_tdata ),
       .m_tvalid   (fifoOut_axim_tvalid)
      );

 // fsm to control the flow of the architecture
    fsm fsm_inst (
       .clk                (clk),
       .rstn               (rstn),

       .load_weight_en     (wr_weight_en),
       .load_weight_done   (wr_weight_done),
       .load_data_exec_done(pe_array_done),
       .adder_done         (adder_done),
       .write_output_done  (fifoOut_axis_tready),
       .is_last            (is_last),

       .adder_en           ( fsm_adder_en)
    );


endmodule
