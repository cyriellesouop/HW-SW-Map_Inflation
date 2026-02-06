`timescale 1ns/1ps

module top #(
    parameter KERNEL_SIZE  = 3, // 16x16 Matrix
    parameter DATA_WIDTH   = 8,
    parameter WEIGHT_WIDTH = 8,
    parameter DEPTH        = 4, // FIFO depth
    parameter PTR_WIDTH    = 2,   // clog2(4)
    parameter BUS_WIDTH = 32  //the data bus width
)(
    input  clk,
    input  rstn,

    // AXI Stream Slave Interface
    input   [BUS_WIDTH - 1 : 0]               s_axis_tdata,
    input                                     s_axis_tvalid,
    output                                    s_axis_tready,
    // AXI Stream Master Interface
    input                                     m_axis_tready,
    output [(DATA_WIDTH+WEIGHT_WIDTH+KERNEL_SIZE) * KERNEL_SIZE-1 :0]  m_axis_tdata,
   // output  [BUS_WIDTH - 1 : 0]               m_axis_tdata,
    output                                    m_axis_tvalid
);
    localparam DATAOUT_WIDTH = (DATA_WIDTH+WEIGHT_WIDTH+KERNEL_SIZE) * KERNEL_SIZE;  // size of the dataOut produces by the pe_wrapper.
    localparam DATAIN_WIDTH = DATA_WIDTH * KERNEL_SIZE ;  // size of the dataIn of the pe_wrapper
    localparam WEIGHTIN_WIDTH = WEIGHT_WIDTH * KERNEL_SIZE * KERNEL_SIZE;   // size of the input weights 
    localparam TOTAL_BYTES = KERNEL_SIZE * KERNEL_SIZE;  // each weight is on 8 bits(1byte). So the total byte of a weight bus is equal to the kernel  dimension : KERNEL_SIZE * KERNEL_SIZE
     

    // Weight loader signals
    wire weight_loader_ready;
    wire is_loading_weights;
    wire weights_loaded;
    wire [WEIGHTIN_WIDTH - 1 : 0] flat_weights;
    
     // Data accumulator signals (32-bit to full row)
    wire accumulator_ready;
    wire [(KERNEL_SIZE * DATA_WIDTH) - 1 : 0] accumulated_row;
    wire accumulated_valid;
    
    // pe_wrapper signals
    wire unpacker_ready;
    wire [(KERNEL_SIZE * DATA_WIDTH) - 1 : 0] fifo_m_tdata;
    wire [KERNEL_SIZE - 1 : 0] fifo_m_tvalid;
    wire [KERNEL_SIZE - 1 : 0] fifo_m_tready;
    wire ready_pe_wrapper;
    wire pe_done;
    wire [DATAOUT_WIDTH - 1 : 0] pe_dataout;

    // output FIFO signals
    wire output_fifo_ready;
    wire [(WEIGHT_WIDTH * KERNEL_SIZE * KERNEL_SIZE) - 1 : 0] weight_for_pe;// Define the correctly ordered weight bus

    // During weight loading: route input to weight loader
    // During streaming: route input to data accumulator
    assign s_axis_tready = is_loading_weights ? weight_loader_ready : accumulator_ready;


    // FULLY PIPELINED: PE processes whenever data is available
    wire pe_en = (&fifo_m_tvalid || pe_done) && (ready_pe_wrapper && output_fifo_ready); //(&fifo_m_tvalid) && ready_pe_wrapper && output_fifo_ready;
    
       
         //to put weights in the right order : Reverse the byte order 
	genvar b;
	generate
	    for (b = 0; b < (KERNEL_SIZE * KERNEL_SIZE); b = b + 1) begin 
		assign weight_for_pe[b*WEIGHT_WIDTH +: WEIGHT_WIDTH] = flat_weights[(TOTAL_BYTES - 1 - b)*WEIGHT_WIDTH +: WEIGHT_WIDTH]; //weigth to assign to pe
	    end
	endgenerate
    
    // Read from all FIFOs simultaneously when PE processes
    assign fifo_m_tready = {KERNEL_SIZE{pe_en}};
    // Only pull from the FIFO if the PE is enabled AND the FIFO actually has data
   //assign fifo_m_tready = {KERNEL_SIZE{pe_en && (&fifo_m_tvalid)}};



    // 1. FSM fpr  Weight Loader
    weight_loader #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .BUS_WIDTH(BUS_WIDTH)
    ) weight_loader_inst (
        .clk(clk),
        .rstn(rstn),
        
        // Input interface
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(weight_loader_ready),
        
        // Weight output
        .weights_out(flat_weights),
        
        // Status
        .loading(is_loading_weights)
       // .done_loading(weights_loaded)
    );
    
    
    
    // 2. Data Accumulator (32-bit to full row)
    // Converts multiple 32-bit transfers into one full row of KERNEL_SIZE pixels
    data_accumulator #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .BUS_WIDTH(BUS_WIDTH)
    ) accumulator_inst (
        .clk(clk),
        .rstn(rstn),
        
        // Enable only when NOT loading weights
        .enable(!is_loading_weights),
        
        // Slave interface (only active when not loading weights)
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        //.s_axis_tvalid(!is_loading_weights && s_axis_tvalid),
        .s_axis_tready(accumulator_ready),
        
        // Master interface (full row output)
        .m_axis_tready(unpacker_ready),
        .m_axis_tdata(accumulated_row),
        .m_axis_tvalid(accumulated_valid)
    );


     // 3. Data Unpacker with Input FIFOs
    axis_unpack_data #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .PTR_WIDTH(PTR_WIDTH)
    ) unpacker (
        .clk(clk),
        .rstn(rstn),
        
        // Slave interface (receives full rows from accumulator)
        .s_axis_tdata(accumulated_row),
        .s_axis_tvalid(accumulated_valid),
        .s_axis_tready(unpacker_ready),
        
        // Master interface to PE
        .m_axis_tready(fifo_m_tready),
        .m_axis_tdata(fifo_m_tdata),
        .m_axis_tvalid(fifo_m_tvalid)
    );


    // 4. PE Wrapper
    pe_wrapper #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .WEIGHT_WIDTH(WEIGHT_WIDTH)
    ) pe_engine (
        .clk(clk),
        .rstn(rstn),

	// control
        .en(pe_en),
        .ready(ready_pe_wrapper),

	//Data inputs
        .dataIn(fifo_m_tdata),
        .weightsIn(weight_for_pe),

	// Data outputs
        .dataOut(pe_dataout),
        .dataOut_done(pe_done)
    );

   
   /* 
    // 5.output FIFO
    fifo_axis #(
        .DATAWIDTH(DATAOUT_WIDTH),
        .DEPTH(DEPTH),  // Match input FIFO depth
        .PTR_WIDTH(PTR_WIDTH)
    ) output_fifo (
        .clk(clk),
        .rstn(rstn),

        // Input from PE_wrapper (producer)
        .s_tvalid(pe_done),
        .s_tdata(pe_dataout),
        .s_tready(output_fifo_ready),

        // Output to DMA (consumer)
        .m_tready(m_axis_tready),
        .m_tdata(m_axis_tdata),
        .m_tvalid(m_axis_tvalid)
    );

     */
endmodule
