`timescale 1ns/1ps
// =============================================================================
// adder_tree.v  —  Fixed (Issue 2) — Pure Verilog-2001
//
// ISSUE 2 FIX — Linear ripple-chain replaced with registered binary adder tree:
//
//   Original Stage 2 was a single combinational always @(*) loop:
//       for (i=0; i<KERNEL_SIZE; i++) full_sum = full_sum + products[i];
//   This synthesises as a serial K-level adder chain (critical path = O(K)),
//   limiting Fmax as the kernel grows.
//
//   Fixed: LEVELS = ceil(log2(KERNEL_SIZE)) registered pipeline stages.
//   Each stage pairs adjacent partial sums, halving the operand count.
//   Critical path per stage = one 2-input adder = O(1), regardless of K.
//
//   Example  KERNEL_SIZE = 3  (LEVELS = 2):
//     Stage-0 register : product[0], product[1], product[2]
//     Level-1 register : sum_01 = p[0]+p[1],  pass_2 = p[2]
//     Level-2 register : final  = sum_01 + pass_2   --> FIFO input
//
//   Storage layout — flattened 1-D array indexed as:
//     tree_flat[level * KERNEL_SIZE + element]
//
//   Total pipeline latency  : LEVELS + 1 register stages (was 2 stages)
//   Critical path per stage : 1 x 2-input addition    (was K-input chain)
// =============================================================================

module adder_tree #(
    parameter KERNEL_SIZE  = 3,   // Number of products to sum
    parameter DATA_WIDTH   = 8,   // Width of input pixel
    parameter WEIGHT_WIDTH = 8,   // Width of kernel weight
    parameter DEPTH        = 8,   // FIFO depth
    parameter PTR_WIDTH    = 3    // FIFO pointer width
)(
    input  clk,
    input  rstn,

    // Write interface (from PE row)
    input  adder_en,
    input  [(DATA_WIDTH + WEIGHT_WIDTH) * KERNEL_SIZE - 1 : 0] adder_dataIn,

    // AXI-Stream Master Interface (to downstream)
    input  m_axis_tready,
    output [(DATA_WIDTH + WEIGHT_WIDTH + $clog2(KERNEL_SIZE)) - 1 : 0] m_axis_tdata,
    output m_axis_tvalid
);

    // -------------------------------------------------------------------------
    // Local parameters
    // -------------------------------------------------------------------------
    localparam PRODUCT_WIDTH     = DATA_WIDTH + WEIGHT_WIDTH;
    localparam PARTIAL_SUM_WIDTH = PRODUCT_WIDTH + $clog2(KERNEL_SIZE);
    localparam FINAL_OUT_WIDTH   = PARTIAL_SUM_WIDTH;

    // Number of binary tree levels  (ceil of log2, min 1)
    localparam LEVELS = (KERNEL_SIZE > 1) ? $clog2(KERNEL_SIZE) : 1;

    // -------------------------------------------------------------------------
    // Pipeline storage
    //   Flattened 2-D array  tree_flat[ level * KERNEL_SIZE + element ]
    //   Levels : 0 (input regs) .. LEVELS (final sum)
    //   Elements per level : KERNEL_SIZE (upper levels have fewer valid slots;
    //                         unused slots are don't-care)
    // -------------------------------------------------------------------------
    reg [PARTIAL_SUM_WIDTH-1:0] tree_flat [0:((LEVELS+1)*KERNEL_SIZE)-1];

    // Valid flag for each level — propagated from the adder_en strobe
    reg tree_en [0:LEVELS];

    // -------------------------------------------------------------------------
    // Back-pressure: stall entire pipeline when the output FIFO is full
    // -------------------------------------------------------------------------
    wire fifo_s_tready;
    wire pipe_en = fifo_s_tready || !tree_en[LEVELS];

    // Final result: element 0 of the last level
    wire                      fifo_s_tvalid = tree_en[LEVELS];
    wire [FINAL_OUT_WIDTH-1:0] fifo_s_tdata = tree_flat[LEVELS * KERNEL_SIZE];

    // -------------------------------------------------------------------------
    // Stage 0 — Register raw product inputs
    // -------------------------------------------------------------------------
    integer j;
    always @(posedge clk) begin
        if (!rstn) begin
            tree_en[0] <= 1'b0;
            for (j = 0; j < KERNEL_SIZE; j = j + 1)
                tree_flat[j] <= {PARTIAL_SUM_WIDTH{1'b0}};
        end else if (pipe_en) begin
            tree_en[0] <= adder_en;
            for (j = 0; j < KERNEL_SIZE; j = j + 1) begin
                if (adder_en)
                    // Zero-extend product to PARTIAL_SUM_WIDTH before storing
                    tree_flat[j] <= {{(PARTIAL_SUM_WIDTH-PRODUCT_WIDTH){1'b0}},
                                      adder_dataIn[j*PRODUCT_WIDTH +: PRODUCT_WIDTH]};
                else
                    tree_flat[j] <= {PARTIAL_SUM_WIDTH{1'b0}};
            end
        end
    end

    // -------------------------------------------------------------------------
    // Levels 1 .. LEVELS  — Generated binary adder tree
    //
    // For each level l (genvar), IN_COUNT is the number of elements entering
    // from level l, OUT_COUNT is the number of pairs produced.
    //
    //   IN_COUNT  = ceil( KERNEL_SIZE / 2^l )  [elements entering this level]
    //   OUT_COUNT = ceil( IN_COUNT   / 2    )  [pairs this level produces]
    //
    // If IN_COUNT is odd, the last element is passed through (no addition).
    // The loop over k is fully unrolled by synthesis (OUT_COUNT is a constant).
    // -------------------------------------------------------------------------
    genvar l;
    generate
        for (l = 0; l < LEVELS; l = l + 1) begin : gen_tree_level

            // Elements entering this level  (= ceil(KERNEL_SIZE / 2^l))
            localparam IN_COUNT  = (KERNEL_SIZE + (1 << l) - 1) / (1 << l);
            // Pairs produced by this level  (= ceil(IN_COUNT / 2))
            localparam OUT_COUNT = (IN_COUNT + 1) / 2;

            integer k;
            always @(posedge clk) begin
                if (!rstn) begin
                    tree_en[l+1] <= 1'b0;
                    for (k = 0; k < KERNEL_SIZE; k = k + 1)
                        tree_flat[(l+1)*KERNEL_SIZE + k] <= {PARTIAL_SUM_WIDTH{1'b0}};
                end else if (pipe_en) begin
                    // Propagate valid strobe
                    tree_en[l+1] <= tree_en[l];

                    for (k = 0; k < OUT_COUNT; k = k + 1) begin
                        if (2*k + 1 < IN_COUNT)
                            // Pair: add two adjacent elements from previous level
                            tree_flat[(l+1)*KERNEL_SIZE + k] <=
                                tree_flat[l*KERNEL_SIZE + 2*k    ] +
                                tree_flat[l*KERNEL_SIZE + 2*k + 1];
                        else
                            // Odd last element: pass through without addition
                            tree_flat[(l+1)*KERNEL_SIZE + k] <=
                                tree_flat[l*KERNEL_SIZE + 2*k];
                    end
                end
            end

        end
    endgenerate

    // -------------------------------------------------------------------------
    // Output FIFO (AXI-Stream wrapper, unchanged from original)
    // -------------------------------------------------------------------------
    fifo_axis #(
        .DATAWIDTH (FINAL_OUT_WIDTH),
        .DEPTH     (DEPTH),
        .PTR_WIDTH (PTR_WIDTH)
    ) fifo_axis_inst (
        .clk      (clk),
        .rstn     (rstn),
        .s_tvalid (fifo_s_tvalid),
        .s_tdata  (fifo_s_tdata),
        .s_tready (fifo_s_tready),
        .m_tready (m_axis_tready),
        .m_tdata  (m_axis_tdata),
        .m_tvalid (m_axis_tvalid)
    );

endmodule
