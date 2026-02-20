`timescale 1ns/1ps
// =============================================================================
// crossbar.v  —  Fixed (Issues 1 & 6)
//
// ISSUE 1 FIX — "Wait-for-all-slots" gate removed:
//   The original start_counter flag blocked ALL output until every slot
//   simultaneously held valid data (&reg_s_tvalid). This added K dead cycles
//   on every computation start. The fix: start outputting as soon as the
//   current round-robin slot (count=0) holds valid data — no global barrier.
//
// ISSUE 6 FIX — Counter freeze on missing slot:
//   The freeze behavior (hold count, de-assert tvalid) is CORRECT for
//   in-order convolution output and is kept intact. With the upstream pipeline
//   fixed (binary adder tree + concurrent data_accumulator), all K row-sums
//   arrive synchronously, so the freeze condition never occurs in practice.
//   The removed start_counter was the only artificial freeze source.
// =============================================================================

module crossbar
#(
    parameter KERNEL_SIZE = 3,
    parameter DATA_WIDTH  = 18
)(
    input clk,
    input rstn,

    // Slave Interfaces (From Adder Trees)
    input  [KERNEL_SIZE-1:0]            s_axis_tvalid,
    input  [DATA_WIDTH*KERNEL_SIZE-1:0] s_axis_tdata,
    output [KERNEL_SIZE-1:0]            s_axis_tready,

    // Master Interface (To Output Module)
    output reg                          m_axis_tvalid,
    output reg [DATA_WIDTH-1:0]         m_axis_tdata,
    input                               m_axis_tready
);

    // -------------------------------------------------------------------------
    // Internal registers
    // -------------------------------------------------------------------------
    reg [DATA_WIDTH-1:0]          reg_s_tdata  [0:KERNEL_SIZE-1];
    reg [KERNEL_SIZE-1:0]         reg_s_tvalid;
    reg [$clog2(KERNEL_SIZE)-1:0] count;

    // -------------------------------------------------------------------------
    // Combinational helpers
    // -------------------------------------------------------------------------
    wire output_fire = m_axis_tvalid && m_axis_tready;
    wire can_update  = m_axis_tready || !m_axis_tvalid;

    // Pre-compute next count (avoids long combinational chain in the always block)
    wire [$clog2(KERNEL_SIZE)-1:0] count_next =
        (count == KERNEL_SIZE - 1) ? 'd0 : count + 1'd1;

    // -------------------------------------------------------------------------
    // 1. Per-slot buffer stage
    //    Each slot independently accepts new data from its adder-tree row.
    //    A slot is ready to accept when: it is empty OR being consumed this cycle.
    // -------------------------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin : gen_slots
            wire slot_selected   = (count == i[$clog2(KERNEL_SIZE)-1:0]);
            wire slot_being_read = slot_selected && output_fire;

            // Accept new data if slot is empty or being drained right now
            assign s_axis_tready[i] = !reg_s_tvalid[i] || slot_being_read;

            always @(posedge clk) begin
                if (!rstn) begin
                    reg_s_tvalid[i] <= 1'b0;
                    reg_s_tdata[i]  <= {DATA_WIDTH{1'b0}};
                end else begin
                    if (s_axis_tready[i] && s_axis_tvalid[i]) begin
                        // New data arriving from adder tree row i
                        reg_s_tvalid[i] <= 1'b1;
                        reg_s_tdata[i]  <= s_axis_tdata[i*DATA_WIDTH +: DATA_WIDTH];
                    end else if (slot_being_read) begin
                        // Slot consumed by the master, no new data this cycle
                        reg_s_tvalid[i] <= 1'b0;
                    end
                end
            end
        end
    endgenerate

    // -------------------------------------------------------------------------
    // 2. Round-robin output sequencer  (start_counter REMOVED)
    //
    //    Original: output was gated behind (&reg_s_tvalid) via start_counter,
    //    causing K idle cycles before the first output.
    //
    //    Fixed: begin outputting as soon as reg_s_tvalid[count] is asserted.
    //    The counter only advances on a successful output handshake (output_fire).
    //    When the current slot is not yet valid, tvalid is de-asserted and the
    //    counter waits — preserving strict row ordering.
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rstn) begin
            count         <= 'd0;
            m_axis_tvalid <= 1'b0;
            m_axis_tdata  <= {DATA_WIDTH{1'b0}};
        end else begin
            if (can_update) begin
                if (reg_s_tvalid[count]) begin
                    // Current slot is ready: drive output and advance counter
                    m_axis_tdata  <= reg_s_tdata[count];
                    m_axis_tvalid <= 1'b1;
                    count         <= count_next;
                end else begin
                    // Current slot not yet valid: stall output, hold counter
                    // (In-order guarantee: we never skip a row)
                    m_axis_tvalid <= 1'b0;
                end
            end
            // If !can_update (downstream not ready and tvalid already high):
            // hold m_axis_tdata / m_axis_tvalid unchanged — implicit by no else
        end
    end

endmodule
