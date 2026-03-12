`timescale 1ns/1ps


/*   LEVELS = ceil(log2(KERNEL_SIZE)) registered pipeline stages.
   Each stage pairs adjacent partial sums, halving the operand count.
   Critical path per stage = 1 2-input adder = O(1), regardless of Kernel_size.

   Example  KERNEL_SIZE = 3  (LEVELS = 2)
   Stage-0 register : product[0], product[1], product[2]
   Level-1 register : sum_01 = p[0]+p[1],  pass_2 = p[2]
   Level-2 register : final  = sum_01 + pass_2   --> FIFO input
   Total pipeline latency  : LEVELS + 1 register stages (was 2 stages)*/

module adder_tree #(
    parameter KERNEL_SIZE  = 3,   // Number of products to sum
    parameter DATA_WIDTH   = 8,   // Width of input pixel
    parameter WEIGHT_WIDTH = 8,   // Width of kernel weight
    parameter DEPTH        = 8,   // FIFO depth
    parameter PTR_WIDTH    = 3    // FIFO pointer width
)(
    input  clk,
    input  rstn,

    // Write interface 
    input  adder_en,
    input  [(DATA_WIDTH + WEIGHT_WIDTH) * KERNEL_SIZE - 1 : 0] adder_dataIn,

    // AXI-Stream Master Interface 
    input  m_axis_tready,
    output [(DATA_WIDTH + WEIGHT_WIDTH + $clog2(KERNEL_SIZE)) - 1 : 0] m_axis_tdata,
    output m_axis_tvalid
);

    localparam PRODUCT_WIDTH     = DATA_WIDTH + WEIGHT_WIDTH;
    localparam PARTIAL_SUM_WIDTH = PRODUCT_WIDTH + $clog2(KERNEL_SIZE);
    localparam FINAL_OUT_WIDTH   = PARTIAL_SUM_WIDTH;
    localparam LEVELS = (KERNEL_SIZE > 1) ? $clog2(KERNEL_SIZE) : 1; // Number of binary tree levels
    
   /*   
   Example  KERNEL_SIZE = 3  (LEVELS = 2)
   Stage-0 register : product[0], product[1], product[2]
   Level-1 register : sum_01 = p[0]+p[1],  pass_2 = p[2]
   Level-2 register : final  = sum_01 + pass_2   --> FIFO input
   Total pipeline latency  : LEVELS + 1 register stages (was 2 stages)
   
   Pipeline storage:
      Levels: 0 (input regs) ------> LEVELS (final sum)
      Elements per level : KERNEL_SIZE  
   */
   
    reg [PARTIAL_SUM_WIDTH-1:0] tree_flat [0:((LEVELS+1)*KERNEL_SIZE)-1]; // Flattened 2-D array  tree_flat[ level * KERNEL_SIZE + element ]
    reg tree_en [0:LEVELS]; // Valid flag for each level (coming from adder_en signal)

    wire fifo_s_tready;
    wire pipe_en = fifo_s_tready || !tree_en[LEVELS]; // pipeline enable if fifo is not full or the pipeline itself is not yet full meaning that the final stage is empty

    wire fifo_s_tvalid = tree_en[LEVELS];
    wire [FINAL_OUT_WIDTH-1:0] fifo_s_tdata = tree_flat[LEVELS * KERNEL_SIZE]; // element 0 of the last level hold the final result

    // Stage 0 — Register inputs
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
                    tree_flat[j] <= {{(PARTIAL_SUM_WIDTH-PRODUCT_WIDTH){1'b0}}, adder_dataIn[j*PRODUCT_WIDTH +: PRODUCT_WIDTH]}; //extend each products from  adder_dataIn to PARTIAL_SUM_WIDTH before storing
                else
                    tree_flat[j] <= {PARTIAL_SUM_WIDTH{1'b0}};
            end
        end
    end

    // stage 1 -  Generated binary adder tree
    // If IN_COUNT is odd, the last element is passed through (no addition).
    genvar l;
    generate
        for (l = 0; l < LEVELS; l = l + 1) begin
            localparam IN_COUNT  = (KERNEL_SIZE + (1 << l) - 1) / (1 << l); // we round up the number of operands waiting at the entrance of the current level by adding (2^l - 1) to the kernel size
            localparam OUT_COUNT = (IN_COUNT + 1) / 2;  // The number of results this level will produce

            integer k;
            always @(posedge clk) begin
                if (!rstn) begin
                    tree_en[l+1] <= 1'b0;
                    for (k = 0; k < KERNEL_SIZE; k = k + 1)
                        tree_flat[(l+1)*KERNEL_SIZE + k] <= {PARTIAL_SUM_WIDTH{1'b0}};
                end else if (pipe_en) begin
                    tree_en[l+1] <= tree_en[l];

                    for (k = 0; k < OUT_COUNT; k = k + 1) begin
                        if (2*k + 1 < IN_COUNT)
                            // Pair: add two adjacent elements from previous level
		            // + k part moves the algorithm through elements within one level
			    // l * KERNEL_SIZE part jumps the algorithm to the start of the next level's storage block
                            tree_flat[(l+1)*KERNEL_SIZE + k] <= tree_flat[l*KERNEL_SIZE + 2*k] + tree_flat[l*KERNEL_SIZE + 2*k + 1];
                        else
                            // IN_COUNT is odd : pass last element through without addition
                            tree_flat[(l+1)*KERNEL_SIZE + k] <= tree_flat[l*KERNEL_SIZE + 2*k]; 
                    end
                end
            end

        end
    endgenerate

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
