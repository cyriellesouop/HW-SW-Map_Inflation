`timescale 1ns/1ps

module data_accumulator #
(
    parameter integer KERNEL_SIZE = 5,
    parameter integer DATA_WIDTH  = 8,
    parameter integer BUS_WIDTH   = 32
)
(
    input   clk,
    input   rstn,
    input   enable,
   // input   is_loading_weights,      // this signal indicate the weight loading phase

    // AXI-Stream input
    input  [BUS_WIDTH-1:0] s_axis_tdata,
    input                  s_axis_tvalid,
    output                 s_axis_tready,

    // AXI-Stream output (one row = KERNEL_SIZE elements)
    output reg  [KERNEL_SIZE*DATA_WIDTH-1:0] m_axis_tdata,
    output reg                               m_axis_tvalid,
    input                                m_axis_tready
);

    // derived parameters
    localparam integer WORD_ELEMS = BUS_WIDTH / DATA_WIDTH;  //// How many DATA_WIDTH elements fit inside one AXI word
    localparam integer SR_ELEMS   = 2 * KERNEL_SIZE;         // Total number of elts stored in the internal shif register : we keep it twice the kernel size so we can slide a window
    localparam integer SR_BITS    = SR_ELEMS * DATA_WIDTH;   // Total number of bits of the shift register

    // shift register
    reg [SR_BITS-1:0] shift_reg;   // Main shift register that stores incoming elements( DTA_WIDTH elements)
    reg [$clog2(SR_ELEMS+1)-1:0] elem_count;  // Number of Valid elts stored in shift register

    // FSM
       typedef enum {ST_FILL, ST_OUT} state_t; // ST_FILL : state to accept and store incorming word. ST_OUT : State to output one KErnel_Size window
    state_t state;


    // small one word input buffer to prevent losing a word when we cannot immediately push into the shift register
    reg [BUS_WIDTH-1:0] in_buf_data;  // buffer input word
    reg                 in_buf_valid;  // buffer contains valid data

    // AXI ready
    assign s_axis_tready = enable && !in_buf_valid;

    always @(posedge clk) begin
        if (!rstn) begin
            shift_reg      <= '0;
            elem_count     <= 0;
            m_axis_tdata   <= '0;
            m_axis_tvalid  <= 1'b0;
            state          <= ST_FILL;  // we satrt in  fill mode
            in_buf_data    <= '0;
            in_buf_valid   <= 1'b0;
        end
        else begin
            // default
            m_axis_tvalid <= 1'b0;

            /* When upstream and this block perform a handshake (tvalid & tready), 
            we store the incoming word in a small internal buffer. */
            if (s_axis_tvalid && s_axis_tready) begin
                in_buf_data  <= s_axis_tdata;
                in_buf_valid <= 1'b1;
            end

            case (state)

            // FILL: accept data
            ST_FILL: begin
            
            // // Only act if we actually have buffered data
                if (in_buf_valid) begin
                    shift_reg <= { shift_reg[SR_BITS-BUS_WIDTH-1:0], in_buf_data }; // oldest data is shifted out on the MSB side and the new data in_buf_data append at the LSB side
                    if (elem_count + WORD_ELEMS >= SR_ELEMS)
                        elem_count <= SR_ELEMS;
                    else
                        elem_count <= elem_count + WORD_ELEMS;

                    in_buf_valid <= 1'b0; // buffered word is consumed
                end

                if (elem_count >= KERNEL_SIZE)  //Once we have at least KERNEL_SIZE elements, we are allowed to produce one output window
                    state <= ST_OUT;
            end

            // Output one row
            ST_OUT: begin
            // Only send data when m_axis_tready is asserted
                if (m_axis_tready) begin
                    m_axis_tdata  <= shift_reg[elem_count*DATA_WIDTH-1 -: KERNEL_SIZE*DATA_WIDTH]; // select Kernel_size elts from the shift register. The row is taken from the top of the valid region(new vali data)
                    m_axis_tvalid <= 1'b1;
                    elem_count    <= elem_count - KERNEL_SIZE; // we have consumed Kernel_size elements
                    state         <= ST_FILL;
                end
            end

            endcase
        end
    end
endmodule
