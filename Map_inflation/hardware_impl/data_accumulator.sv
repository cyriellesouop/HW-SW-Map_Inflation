`timescale 1ns/1ps

module data_accumulator #(
    parameter KERNEL_SIZE = 3,
    parameter DATA_WIDTH  = 8,
    parameter BUS_WIDTH   = 32
)(
    input  clk,
    input  rstn,
     
    // Control signal - enable accumulator (should be low during weight loading)
    input                       enable,
    
    // AXI Stream Slave Interface (32-bit input)
    input  [BUS_WIDTH - 1 : 0]  s_axis_tdata,
    input                       s_axis_tvalid,
    output                      s_axis_tready,
    
    // AXI Stream Master Interface (Full row output)
    input                       m_axis_tready,
    output [(DATA_WIDTH * KERNEL_SIZE) - 1 : 0] m_axis_tdata,
    output                      m_axis_tvalid
);

    // Local parameters
    localparam REQUIRED_BITS = DATA_WIDTH * KERNEL_SIZE;
    localparam NUM_TRANSFERS = (REQUIRED_BITS + BUS_WIDTH - 1) / BUS_WIDTH;
    localparam PADDED_SIZE   = NUM_TRANSFERS * BUS_WIDTH; // Standardizes the shift register
    
    // Internal signals
    reg [PADDED_SIZE - 1 : 0] row_buffer;
    integer transfer_count;
    //reg [$clog2(NUM_TRANSFERS) : 0] transfer_count;
    reg row_valid;
    
    // State definition
    typedef enum {ACCUMULATING, OUTPUTTING} state_t;
    state_t state;
    
    // Assignments
    assign s_axis_tready = (state == ACCUMULATING);
    assign m_axis_tvalid = row_valid;
    
    // Slice only the bits we need for the output
    //assign m_axis_tdata = row_buffer[REQUIRED_BITS - 1 : 0];
    
    // This takes the first 'REQUIRED_BITS' from the most significant part of the buffer
    assign m_axis_tdata = row_buffer[PADDED_SIZE - 1 : PADDED_SIZE - REQUIRED_BITS];
    
    // Accumulator FSM
    always @(posedge clk) begin
        if (!rstn || !enable) begin //|| !enable
            state <= ACCUMULATING;
            transfer_count <= 0;
            row_buffer <= 0;
            row_valid <= 1'b0;
        end else begin
            case (state)
                ACCUMULATING: begin
                    if (s_axis_tvalid && s_axis_tready) begin
                        // Shift in 32 bits from the bottom
                        // Check if we have more than one bus-width of data
                        if (PADDED_SIZE > BUS_WIDTH) begin 
                            row_buffer <= {row_buffer[PADDED_SIZE - BUS_WIDTH - 1 : 0], s_axis_tdata}; // Standard shift: Shift left, insert new data at the LSBs
                        end 
                        else begin
                            row_buffer <= s_axis_tdata; // If the row is only 1 bus-width wide, just load the data
                        end
                        
                        if (transfer_count == NUM_TRANSFERS - 1) begin
                            row_valid <= 1'b1;   // we have a valid complete  row 
                            transfer_count <= 0;
                            state <= OUTPUTTING;
                        end else begin
                            transfer_count <= transfer_count + 1;
                        end
                    end
                end
               
	       //the OUTPUTTING state ensuring the data is consumed before new data is produced.	
                OUTPUTTING: begin
                    if (m_axis_tready) begin
                        row_valid <= 1'b0;   //when the row is ready to be consumed(by a slave interface), the complete row is not longer valid
                        state <= ACCUMULATING;
                    end
                end
                
                default: state <= ACCUMULATING;
            endcase
        end
    end

endmodule
