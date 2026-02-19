`timescale 1ns/1ps

module data_accumulator #
(
    parameter integer KERNEL_SIZE = 5,
    parameter integer DATA_WIDTH  = 8,
    parameter integer BUS_WIDTH   = 32
)
(
    input  wire clk,
    input  wire rstn,
    input  wire enable,
    input  wire is_loading_weights,  // added input to track weight loading

    // ----------------------------
    // AXI-Stream input
    // ----------------------------
    input  wire [BUS_WIDTH-1:0] s_axis_tdata,
    input  wire                 s_axis_tvalid,
    output wire                 s_axis_tready,

    // ----------------------------
    // AXI-Stream output
    // one row = KERNEL_SIZE elements
    // ----------------------------
    output reg  [KERNEL_SIZE*DATA_WIDTH-1:0] m_axis_tdata,
    output reg                               m_axis_tvalid,
    input  wire                              m_axis_tready
);

    // ------------------------------------------------------------
    // derived parameters
    // ------------------------------------------------------------
    localparam integer WORD_ELEMS = BUS_WIDTH / DATA_WIDTH;
    localparam integer SR_ELEMS   = 2 * KERNEL_SIZE;
    localparam integer SR_BITS    = SR_ELEMS * DATA_WIDTH;

    // ------------------------------------------------------------
    // shift register
    // newest elements are on the LSB side
    // ------------------------------------------------------------
    reg [SR_BITS-1:0] shift_reg;

    // number of valid elements currently stored
    reg [$clog2(SR_ELEMS+1)-1:0] elem_count;

    // ------------------------------------------------------------
    // FSM
    // ------------------------------------------------------------
 /*   localparam ST_FILL = 1'b0;
    localparam ST_OUT  = 1'b1;
    reg state; */
    
    typedef enum {ST_FILL, ST_OUT} state_t;
    state_t state;


    // ------------------------------------------------------------
    // Preload register for first word during weight loading
    // ------------------------------------------------------------
    reg [BUS_WIDTH-1:0] preload_data;
    reg preload_valid;

    always @(posedge clk) begin
        if (!rstn) begin
            preload_data  <= '0;
            preload_valid <= 1'b0;
        end else begin
            // capture first word during weight loading
            if (s_axis_tvalid && is_loading_weights && !preload_valid) begin
                preload_data  <= s_axis_tdata;
                preload_valid <= 1'b1;
            end
            // clear after first use
            if (enable && preload_valid && s_axis_tready) begin
                preload_valid <= 1'b0;
            end
        end
    end

    // ------------------------------------------------------------
    // AXI ready generation
    // ------------------------------------------------------------
    assign s_axis_tready =
            enable &&
            (state == ST_FILL) &&
            (elem_count <= SR_ELEMS - WORD_ELEMS);

    // input data source: preload if valid, else current s_axis_tdata
    wire [BUS_WIDTH-1:0] input_data = preload_valid ? preload_data : s_axis_tdata;

    // ------------------------------------------------------------
    // main FSM
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (!rstn) begin
            shift_reg      <= '0;
            elem_count     <= '0;
            m_axis_tdata   <= '0;
            m_axis_tvalid  <= 1'b0;
            state          <= ST_FILL;
        end
        else begin
            // default
            m_axis_tvalid <= 1'b0;

            case (state)

            // ====================================================
            // Collect input words
            // ====================================================
            ST_FILL: begin
                if (s_axis_tvalid && s_axis_tready) begin
                    // append one BUS word at the right (LSB side)
                    shift_reg
                        <= { shift_reg[SR_BITS-BUS_WIDTH-1:0],
                             input_data };

                    if (elem_count + WORD_ELEMS >= SR_ELEMS)
                        elem_count <= SR_ELEMS;
                    else
                        elem_count <= elem_count + WORD_ELEMS;
                end

                if (elem_count >= KERNEL_SIZE)
                    state <= ST_OUT;
            end

            // ====================================================
            // Output one kernel row
            // ====================================================
            ST_OUT: begin
                if (m_axis_tready) begin
                    // take the oldest KERNEL_SIZE elements
                    m_axis_tdata
                        <= shift_reg[
                            elem_count*DATA_WIDTH-1
                            -: KERNEL_SIZE*DATA_WIDTH
                           ];

                    m_axis_tvalid <= 1'b1;

                    // consume them
                    elem_count <= elem_count - KERNEL_SIZE;

                    state <= ST_FILL;
                end
            end

            endcase
        end
    end

endmodule
