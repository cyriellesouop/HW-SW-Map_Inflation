`timescale 1ns/1ps

module pe_array
#(
    parameter WEIGHT_WIDTH = 1,
    parameter DATA_WIDTH   = 8,
    parameter KERNEL_SIZE  = 3
)
(
    input  clk,
    input  rstn,

    input  [(WEIGHT_WIDTH*KERNEL_SIZE*KERNEL_SIZE)-1:0] weight_array,
    input  wr_weight_en,
    input  [(DATA_WIDTH*KERNEL_SIZE*KERNEL_SIZE)-1:0] dataIn,
    input wr_dataIn_en,

    output reg  wr_weight_done,
    output reg  pe_array_done,
    output reg [(DATA_WIDTH+WEIGHT_WIDTH)*KERNEL_SIZE-1:0] dataOut
);

    localparam RESULT_WIDTH = DATA_WIDTH + WEIGHT_WIDTH;
    localparam KERNEL_DIM   = KERNEL_SIZE*KERNEL_SIZE;

    // Weight memory
    reg [WEIGHT_WIDTH-1:0] weight_mem [0:KERNEL_DIM-1];

    // 2D PE signals
    wire [DATA_WIDTH-1:0]   data_wire   [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1];
    wire [RESULT_WIDTH:0] result_wire [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1];
    wire                     done_wire  [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1];

    reg [KERNEL_DIM-1:0] r;
    reg [KERNEL_SIZE-1:0] c,counter;

    //--------------------------------------------
    // Load weights into weight_mem
    //--------------------------------------------
    always @(posedge clk) begin
        if (!rstn) begin
            wr_weight_done <= 0;
            for (r=0; r<KERNEL_DIM; r=r+1)
                weight_mem[r] <= 0;
        end
        else if (wr_weight_en) begin
            for (r=0; r<KERNEL_DIM; r=r+1)
                weight_mem[r] <= weight_array[(r+1)*WEIGHT_WIDTH-1 -: WEIGHT_WIDTH];
            wr_weight_done <= 1;
        end
        else begin
            wr_weight_done <= 0;
        end
    end

    //--------------------------------------------
    // Instantiate 2D PE array
    //--------------------------------------------
    genvar row, col;
    generate
        for (row=0; row<KERNEL_SIZE; row=row+1) begin : ROW
            for (col=0; col<KERNEL_SIZE; col=col+1) begin : COL

                wire [RESULT_WIDTH:0] prev_result;
                wire [DATA_WIDTH-1:0] pe_dataIn;
                wire pe_en;

                assign prev_result = (row==0) ? 0 : result_wire[row-1][col];
                assign pe_dataIn   = (row==0) ? dataIn[(col+1)*DATA_WIDTH-1 -: DATA_WIDTH]
                                              : data_wire[row-1][col];
                assign pe_en       = (row==0) ? (wr_weight_done && wr_dataIn_en)
                                              : done_wire[row-1][col];

                pe #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .WEIGHT_WIDTH(WEIGHT_WIDTH)
                ) PE_inst (
                    .clk(clk),
                    .rstn(rstn),
                    .dataIn(pe_dataIn),
                    .weight(weight_mem[row*KERNEL_SIZE + col]),
                    .prev_result(prev_result),
                    .pe_en(pe_en),
                    .dataOut(data_wire[row][col]),
                    .next_result(result_wire[row][col]),
                    .pe_done(done_wire[row][col])
                );

            end
        end
    endgenerate

    //--------------------------------------------
    // Collect last row results & assert done
    //--------------------------------------------
    reg all_done;

always @(*) begin
    all_done = 1'b1;
    for (c = 0; c < KERNEL_SIZE; c = c + 1) begin
        if (!done_wire[KERNEL_SIZE-1][c])
            all_done = 1'b0;
    end
end
    always @(posedge clk) begin
        if (!rstn) begin
            pe_array_done <= 0;
            dataOut       <= 0;
        end
        else begin
//            // Check if all last row PEs are done
                 pe_array_done <= all_done; 
            for (c=0; c<KERNEL_SIZE; c=c+1) begin
                // Check if all last row PEs are done
	//	 pe_array_done <= &done_wire[KERNEL_SIZE-1];
	// if (!done_wire[KERNEL_SIZE-1][c]) 
                   // pe_array_done <= 0;

                // Collect last row next_result into dataOut
                dataOut[(c+1)*RESULT_WIDTH-1 -: RESULT_WIDTH] <= result_wire[KERNEL_SIZE-1][c];
            end
	              
        end
    end

endmodule

