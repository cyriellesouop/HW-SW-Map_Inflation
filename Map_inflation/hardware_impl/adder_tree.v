`timescale 1ns/1ps

module adder_tree #(
    parameter KERNEL_SIZE  = 3,  // Number of products to sum
    parameter DATA_WIDTH   = 8,  // Width of input pixel
    parameter WEIGHT_WIDTH = 8,   // Width of kernel weight
    parameter DEPTH = 8, // depth of the fifo
    parameter PTR_WIDTH = 3
)(
    input   clk,
    input   rstn,

    // write interface
    input   adder_en,
    input   [(DATA_WIDTH + WEIGHT_WIDTH) * KERNEL_SIZE - 1 : 0] adder_dataIn,
    // Concatenated PE outputs: each product is (DATA + WEIGHT) bits

    // read interface : AXI-Stream Master Interface (To FIFO)
    input  m_axis_tready,  // downstream is ready to accept data 
    output [(DATA_WIDTH + WEIGHT_WIDTH +  $clog2(KERNEL_SIZE)) - 1 : 0] m_axis_tdata,
    output m_axis_tvalid
);

    // ------------------------------------------------------------------
    // Local parameters
    // ------------------------------------------------------------------
    localparam PRODUCT_WIDTH     = DATA_WIDTH + WEIGHT_WIDTH;
    localparam PARTIAL_SUM_WIDTH = PRODUCT_WIDTH + $clog2(KERNEL_SIZE);
    localparam FINAL_OUT_WIDTH   = PARTIAL_SUM_WIDTH ;

    // ------------------------------------------------------------------
    // Internal signals
    // ------------------------------------------------------------------
    reg [PRODUCT_WIDTH-1:0]     unpacked_products [0:KERNEL_SIZE-1];
    reg [PARTIAL_SUM_WIDTH-1:0] full_sum;

    integer i,j;
    reg output_en;
   
   reg                        fifo_axis_tvalid;
   reg [FINAL_OUT_WIDTH-1:0]   fifo_axis_tdata;
   wire                        fifo_axis_tready;

    // ------------------------------------------------------------------
    // PIPELINE STAGE 1: Register input products
    // ------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rstn) begin
            output_en <= 1'b0;
            for (j = 0; j < KERNEL_SIZE; j = j + 1) begin
                unpacked_products[j] <= {PRODUCT_WIDTH{1'b0}};
            end
        end
        else if (fifo_axis_tready || !fifo_axis_tvalid) begin
            output_en <= adder_en;
            //output_en <= adder_en && fifo_axis_tready ; // we enable output when adder is enable and fifo is not full
            if (adder_en) begin
                for (j = 0; j < KERNEL_SIZE; j = j + 1) begin
                    unpacked_products[j] <= adder_dataIn[(j+1)*PRODUCT_WIDTH-1 -: PRODUCT_WIDTH];
                        
                end
            end
          /*  else begin
                // Clear internal regs when not enabled
                for (j = 0; j < KERNEL_SIZE; j = j + 1) begin
                    unpacked_products[j] <= {PRODUCT_WIDTH{1'b0}};
                end
            end  */          
        end
    end

    // ------------------------------------------------------------------
    // STAGE 2: Combinational addition (adder tree)
    // ------------------------------------------------------------------
    always @(*) begin
        full_sum = {PARTIAL_SUM_WIDTH{1'b0}};
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
            full_sum = full_sum + unpacked_products[i];
        end
    end

    // ------------------------------------------------------------------
    // STAGE 3: Output register
    // ------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rstn) begin
            fifo_axis_tdata <= {FINAL_OUT_WIDTH{1'b0}};
	    fifo_axis_tvalid <= 1'b0;
        end
        else begin
            
	       if (fifo_axis_tready || !fifo_axis_tvalid) begin
                   fifo_axis_tvalid <= output_en;
                   fifo_axis_tdata <=  full_sum;
              end
        end
    end

       fifo_axis #(
        .DATAWIDTH (FINAL_OUT_WIDTH),
        .DEPTH     (DEPTH),
        .PTR_WIDTH (PTR_WIDTH)
    ) fifo_axis_inst (

        .clk      (clk),
        .rstn     (rstn),

        .s_tvalid (fifo_axis_tvalid),
        .s_tdata  (fifo_axis_tdata),
        .s_tready (fifo_axis_tready),

        .m_tready (m_axis_tready),
        .m_tdata  (m_axis_tdata),
        .m_tvalid (m_axis_tvalid)
    );
endmodule

