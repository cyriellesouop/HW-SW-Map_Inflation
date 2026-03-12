`timescale 1ns/1ps

module data_accumulator #(
    parameter KERNEL_SIZE = 3,
    parameter DATA_WIDTH  = 8,
    parameter BUS_WIDTH   = 32
)(
    input  clk,
    input  rstn,
    input  enable,

    // AXI-Stream input : one BUS_WIDTH word
    input  [BUS_WIDTH-1:0] s_axis_tdata,
    input  s_axis_tvalid,
    output  s_axis_tready,

    // AXI-Stream output : one full row (KERNEL_SIZE elements)
    output reg [KERNEL_SIZE*DATA_WIDTH-1:0] m_axis_tdata,
    output reg m_axis_tvalid,
    input m_axis_tready
);

    localparam WORD_ELEMS = BUS_WIDTH / DATA_WIDTH; // elements per AXI word
    localparam SR_ELEMS = 2 * KERNEL_SIZE;        // shift-register capacity is twice the kernel size
    localparam SR_BITS = SR_ELEMS * DATA_WIDTH;  //shift-register datawith is equal to shift-register capacity * data_width of a pixel
    localparam CNT_W = $clog2(SR_ELEMS + 1);
    localparam IDX_W = $clog2(SR_BITS);

    reg [SR_BITS-1:0] shift_reg;
    reg [CNT_W-1:0]   elem_count;
    (* DONT_TOUCH = "TRUE"*) reg [BUS_WIDTH-1:0] in_buf_data;  // One-word input buffer
    (* DONT_TOUCH = "TRUE"*) reg                 in_buf_valid;

    assign s_axis_tready = enable && !in_buf_valid; //Accept new words only when enabled AND the input buffer is free.

    wire can_output = (elem_count >= KERNEL_SIZE);  // We can output a row when there are at least KERNEL_SIZE elements available.
    wire doing_output = can_output && m_axis_tready; // we output a full row when downstream is ready AND we have enough data
    wire [CNT_W-1:0] count_after_output = doing_output ? (elem_count - KERNEL_SIZE) : elem_count; // count element  after output to check whether the shift register has room for a fill

    // We can fill the shift register when there is a buffered word to consume, AND the shift register has room for WORD_ELEMS more elements
    wire can_fill = in_buf_valid && (count_after_output + WORD_ELEMS <= SR_ELEMS);
   
    // To slice it (shift_reg[high -: low]), we need an index variable wide enough to point to the highest bit.
    wire [IDX_W-1:0] safe_high_bit = (elem_count * DATA_WIDTH) - 1; // Calculate the high bit to guaranteed that (elem_count * DATA_WIDTH) - 1 is >=0 even for elem_count= 0 to avoid linter

    always @(posedge clk) begin
        if (!rstn) begin
            shift_reg     <= {SR_BITS{1'b0}};
            elem_count    <= {CNT_W{1'b0}};
            m_axis_tdata  <= {KERNEL_SIZE*DATA_WIDTH {1'b0}};
            m_axis_tvalid <= 1'b0;
            in_buf_data   <= {BUS_WIDTH {1'b0}};
            in_buf_valid  <= 1'b0;
        end else begin
            m_axis_tvalid <= 1'b0;// by default, we de-assert output valid , we will re-asserted if outputting

            // Input buffer capture input data whenever upstream presents valid data AND we are ready.
            if (s_axis_tvalid && s_axis_tready) begin
                in_buf_data  <= s_axis_tdata;
                in_buf_valid <= 1'b1;
            end

            if (can_fill) begin
                shift_reg    <= {shift_reg[SR_BITS-BUS_WIDTH-1:0], in_buf_data}; // Push buffered word into shift register : New data appended at LSB(shift_reg[DATA_WIDTH-1 : 0]) older data shifts toward MSB.
                in_buf_valid <= 1'b0;   // word consumed
            end
            if (doing_output) begin
                //m_axis_tdata  <= shift_reg[(elem_count*DATA_WIDTH)-1 -: (KERNEL_SIZE*DATA_WIDTH)]; // Selects the top KERNEL_SIZE elements of the current valid region
                m_axis_tdata  <= shift_reg[safe_high_bit -: (KERNEL_SIZE*DATA_WIDTH)]; // Selects the top KERNEL_SIZE elements of the current valid region
		m_axis_tvalid <= 1'b1;  // we have a valid row element.
            end

            //elem_count is updated atomically for all combinations : fill only / output only / fill+output simultaneously
            case ({can_fill, doing_output})
                2'b10 : elem_count <= elem_count + WORD_ELEMS;
                2'b01 : elem_count <= elem_count - KERNEL_SIZE;
                2'b11 : elem_count <= elem_count + WORD_ELEMS - KERNEL_SIZE;
                default: ; // 2'b00 : no change
            endcase

        end
    end

endmodule
