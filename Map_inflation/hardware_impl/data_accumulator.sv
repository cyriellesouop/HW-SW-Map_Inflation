`timescale 1ns/1ps
// =============================================================================
// data_accumulator.sv  —  Fixed (Issue 3)
//
// ISSUE 3 FIX — ST_FILL / ST_OUT mutual exclusion removed:
//
//   Original: a two-state FSM (ST_FILL, ST_OUT) made filling and output
//   mutually exclusive.  In every convolution step the module spent one
//   dedicated clock in ST_FILL and one dedicated clock in ST_OUT.  Whenever
//   the downstream was not immediately ready (m_axis_tready=0 while in ST_OUT)
//   the input port was completely stalled — the bus was wasted.
//
//   Fixed: the FSM is removed.  Two independent combinational control signals
//   govern the two paths:
//
//     doing_fill   — consume in_buf into the shift register
//     doing_output — emit a KERNEL_SIZE-wide row to the downstream
//
//   Both can assert in the same clock cycle, saving one cycle per output word
//   whenever data is already buffered.  elem_count is updated atomically for
//   all combinations (fill only / output only / fill+output simultaneously).
//
//   Invariants preserved:
//     • s_axis_tready = enable && !in_buf_valid  (unchanged — 1-word input buf)
//     • Output is suppressed when elem_count < KERNEL_SIZE
//     • Shift register never overflows: fill is blocked when there is no room
//       even after accounting for a simultaneous output
// =============================================================================

module data_accumulator #(
    parameter integer KERNEL_SIZE = 5,
    parameter integer DATA_WIDTH  = 8,
    parameter integer BUS_WIDTH   = 32
)(
    input  clk,
    input  rstn,
    input  enable,

    // AXI-Stream input (one BUS_WIDTH word at a time)
    input  [BUS_WIDTH-1:0] s_axis_tdata,
    input                  s_axis_tvalid,
    output                 s_axis_tready,

    // AXI-Stream output (one full row = KERNEL_SIZE elements)
    output reg [KERNEL_SIZE*DATA_WIDTH-1:0] m_axis_tdata,
    output reg                              m_axis_tvalid,
    input                                   m_axis_tready
);

    // -------------------------------------------------------------------------
    // Derived parameters
    // -------------------------------------------------------------------------
    localparam integer WORD_ELEMS = BUS_WIDTH / DATA_WIDTH;   // elements per AXI word
    localparam integer SR_ELEMS   = 2 * KERNEL_SIZE;           // shift-register capacity
    localparam integer SR_BITS    = SR_ELEMS * DATA_WIDTH;
    localparam integer CNT_W      = $clog2(SR_ELEMS + 1);

    // -------------------------------------------------------------------------
    // State
    // -------------------------------------------------------------------------
    reg [SR_BITS-1:0] shift_reg;
    reg [CNT_W-1:0]   elem_count;

    // One-word elastic input buffer (identical to original)
    reg [BUS_WIDTH-1:0] in_buf_data;
    reg                 in_buf_valid;

    // -------------------------------------------------------------------------
    // AXI-Stream input ready:
    //   Accept new words only when enabled AND the input buffer is free.
    //   (Mutual exclusion between capture and fill is guaranteed by this —
    //    s_axis_tready requires !in_buf_valid, can_fill requires in_buf_valid.)
    // -------------------------------------------------------------------------
    assign s_axis_tready = enable && !in_buf_valid;

    // -------------------------------------------------------------------------
    // Concurrent control signals (combinational from registered state)
    // -------------------------------------------------------------------------

    // We can emit a row when there are at least KERNEL_SIZE elements available.
    wire can_output = (elem_count >= CNT_W'(KERNEL_SIZE));

    // Output handshake: downstream is ready AND we have enough data.
    wire doing_output = can_output && m_axis_tready;

    // Effective element count after a potential simultaneous output.
    // Used to check whether the shift register has room for a fill.
    wire [CNT_W-1:0] count_after_output =
        doing_output ? (elem_count - CNT_W'(KERNEL_SIZE)) : elem_count;

    // We can fill the shift register when:
    //   (a) there IS a buffered word to consume, AND
    //   (b) the shift register has room for WORD_ELEMS more elements
    //       (room is evaluated AFTER the simultaneous output, if any).
    wire can_fill = in_buf_valid &&
                   (count_after_output + CNT_W'(WORD_ELEMS) <= CNT_W'(SR_ELEMS));

    // -------------------------------------------------------------------------
    // Main sequential logic — fill and output run concurrently
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!rstn) begin
            shift_reg     <= '0;
            elem_count    <= '0;
            m_axis_tdata  <= '0;
            m_axis_tvalid <= 1'b0;
            in_buf_data   <= '0;
            in_buf_valid  <= 1'b0;
        end else begin

            // Default: de-assert output valid (re-asserted below if outputting)
            m_axis_tvalid <= 1'b0;

            // ------------------------------------------------------------------
            // Input buffer capture
            //   Runs whenever upstream presents valid data AND we are ready.
            //   Because s_axis_tready = !in_buf_valid and can_fill requires
            //   in_buf_valid, these two paths never collide on in_buf_valid.
            // ------------------------------------------------------------------
            if (s_axis_tvalid && s_axis_tready) begin
                in_buf_data  <= s_axis_tdata;
                in_buf_valid <= 1'b1;
            end

            // ------------------------------------------------------------------
            // Fill path: push buffered word into shift register
            //   New data appended at LSB; older data shifts toward MSB.
            //   Layout: shift_reg[SR_BITS-1 : SR_BITS-DATA_WIDTH] = oldest element
            //            shift_reg[DATA_WIDTH-1 : 0]               = newest element
            // ------------------------------------------------------------------
            if (can_fill) begin
                shift_reg    <= {shift_reg[SR_BITS-BUS_WIDTH-1:0], in_buf_data};
                in_buf_valid <= 1'b0;   // word consumed
            end

            // ------------------------------------------------------------------
            // Output path: emit KERNEL_SIZE-wide row  (concurrent with fill)
            //   Selects the top KERNEL_SIZE elements of the current valid region
            //   from the PRE-FILL shift_reg value (non-blocking — consistent).
            // ------------------------------------------------------------------
            if (doing_output) begin
                m_axis_tdata  <= shift_reg[elem_count*DATA_WIDTH-1 -: KERNEL_SIZE*DATA_WIDTH];
                m_axis_tvalid <= 1'b1;
            end

            // ------------------------------------------------------------------
            // elem_count update — atomic for all four combinations
            // ------------------------------------------------------------------
            case ({can_fill, doing_output})
                2'b10 : elem_count <= elem_count + CNT_W'(WORD_ELEMS);
                2'b01 : elem_count <= elem_count - CNT_W'(KERNEL_SIZE);
                2'b11 : elem_count <= elem_count + CNT_W'(WORD_ELEMS)
                                                  - CNT_W'(KERNEL_SIZE);
                default: ; // 2'b00 : no change
            endcase

        end
    end

endmodule
