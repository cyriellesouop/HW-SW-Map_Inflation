`timescale 1ns/1ps

module top #(
    parameter KERNEL_SIZE  = 16, // 16x16 Matrix
    parameter DATA_WIDTH   = 8,
    parameter WEIGHT_WIDTH = 8,
    parameter DEPTH        = 4, // FIFO depth
    parameter PTR_WIDTH    = 2   // clog2(4)
)(
    input  clk,
    input  rstn,

    // AXI Stream Slave Interface
    input   [(KERNEL_SIZE * DATA_WIDTH) - 1 : 0] s_axis_tdata,
    input                                   s_axis_tvalid,
    output                                  s_axis_tready,
    // AXI Stream Master Interface
    input                                     m_axis_tready,
    output [(DATA_WIDTH+WEIGHT_WIDTH+KERNEL_SIZE) * KERNEL_SIZE-1 :0] m_axis_tdata,
    output                                    m_axis_tvalid
);
    // ------------------------------------------------------------------
    // 1. Weight Storage and Configuration FSM
    // ------------------------------------------------------------------
    reg [WEIGHT_WIDTH-1:0] weight_matrix [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1];
    reg [$clog2(KERNEL_SIZE):0] weight_row_cnt;
    
    localparam S_LOAD_WEIGHTS = 1'b0;
    localparam S_STREAM_DATA  = 1'b1;
    reg state;

    wire is_loading  = (state == S_LOAD_WEIGHTS);
    wire is_streaming = (state == S_STREAM_DATA);

    // Flattened weights for the PE engine
    wire [(WEIGHT_WIDTH * KERNEL_SIZE * KERNEL_SIZE) - 1 : 0] flat_weights;

    always @(posedge clk) begin
        if (!rstn) begin
            state <= S_LOAD_WEIGHTS;
            weight_row_cnt <= 0;
        end else begin
            case (state)
                S_LOAD_WEIGHTS: begin
                    if (s_axis_tvalid && s_axis_tready) begin
                        for (integer i = 0; i < KERNEL_SIZE; i = i + 1) begin
                            weight_matrix[weight_row_cnt][i] <= s_axis_tdata[i*DATA_WIDTH +: WEIGHT_WIDTH];
                        end
                        if (weight_row_cnt == KERNEL_SIZE - 1)
                            state <= S_STREAM_DATA;
                        else
                            weight_row_cnt <= weight_row_cnt + 1;
                    end
                end
                S_STREAM_DATA: state <= S_STREAM_DATA; // Lock until reset
            endcase
        end
    end

    // Map 2D array to flat wire bus
    genvar r, c;
    generate
        for (r = 0; r < KERNEL_SIZE; r = r + 1) begin : rows
            for (c = 0; c < KERNEL_SIZE; c = c + 1) begin : cols
                assign flat_weights[(r*KERNEL_SIZE + c)*WEIGHT_WIDTH +: WEIGHT_WIDTH] = weight_matrix[r][c];
            end
        end
    endgenerate

    // ------------------------------------------------------------------
    // 2. Data Path Interconnects
    // ------------------------------------------------------------------
    wire unpacker_ready;
    wire [(KERNEL_SIZE * DATA_WIDTH) - 1 : 0] fifo_m_tdata;
    wire [KERNEL_SIZE-1:0] fifo_m_tvalid;
    wire [KERNEL_SIZE-1:0] fifo_m_tready;
    wire ready_pe_wrapper;
    wire pe_done;

    // Backpressure & Handshaking
    assign s_axis_tready = is_loading ? 1'b1 : unpacker_ready;
    
    // The PE Wrapper only processes if ALL FIFOs have data AND downstream is ready
    wire pe_en = (&fifo_m_tvalid) && m_axis_tready && ready_pe_wrapper;
    assign fifo_m_tready = {KERNEL_SIZE{pe_en}};

    // ------------------------------------------------------------------
    // 3. Module Instantiations
    // ------------------------------------------------------------------  
    axis_unpack_data #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .PTR_WIDTH(PTR_WIDTH)
    ) unpacker (
        .clk(clk),
        .rstn(rstn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(is_streaming ? s_axis_tvalid : 1'b0), // Gate valid signal
        .s_axis_tready(unpacker_ready),
        .m_axis_tready(fifo_m_tready),
        .m_axis_tdata(fifo_m_tdata),
        .m_axis_tvalid(fifo_m_tvalid)
    );

    pe_wrapper #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .WEIGHT_WIDTH(WEIGHT_WIDTH)
    ) pe_engine (
        .clk(clk),
        .rstn(rstn),
        .en(pe_en),
        .ready(ready_pe_wrapper),
        .dataIn(fifo_m_tdata),
        .weightsIn(flat_weights),
        .dataOut(m_axis_tdata),
        .dataOut_done(pe_done)
    );

    assign m_axis_tvalid = pe_done;

endmodule
