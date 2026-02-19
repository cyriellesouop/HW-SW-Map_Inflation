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
    localparam ST_FILL = 1'b0;
    localparam ST_OUT  = 1'b1;
    reg state;

    // ------------------------------------------------------------
    // 1-word input buffer (for enable=0)
    // ------------------------------------------------------------
    reg [BUS_WIDTH-1:0] in_buf_data;
    reg                 in_buf_valid;

    // ------------------------------------------------------------
    // AXI ready generation
    // ------------------------------------------------------------
    assign s_axis_tready =
        (!in_buf_valid) &&          // buffer free
        (state == ST_FILL) &&
        (elem_count <= SR_ELEMS - WORD_ELEMS);

    // ------------------------------------------------------------
    // main
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (!rstn) begin
            shift_reg      <= '0;
            elem_count     <= '0;
            m_axis_tdata   <= '0;
            m_axis_tvalid  <= 1'b0;
            state          <= ST_FILL;
            in_buf_valid   <= 1'b0;
            in_buf_data    <= '0;
        end
        else begin
            // default output
            m_axis_tvalid <= 1'b0;

            // -------------------------
            // Input buffering
            // -------------------------
            if (s_axis_tvalid && s_axis_tready && !enable) begin
                // capture word when enable=0
                in_buf_data  <= s_axis_tdata;
                in_buf_valid <= 1'b1;
            end

            // -------------------------
            // FSM
            // -------------------------
            case (state)

            // ====================================================
            // Collect input words
            // ====================================================
            ST_FILL: begin
                if (enable &&
                    ((s_axis_tvalid && s_axis_tready && !in_buf_valid) ||
                     in_buf_valid)) begin

                    // shift in either buffered word or current input
                    shift_reg <= { shift_reg[SR_BITS-BUS_WIDTH-1:0],
                                   in_buf_valid ? in_buf_data : s_axis_tdata };

                    // clear buffer if used
                    if (in_buf_valid)
                        in_buf_valid <= 1'b0;

                    // update element count
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
                    m_axis_tdata <= shift_reg[
                        elem_count*DATA_WIDTH-1 -: KERNEL_SIZE*DATA_WIDTH
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
