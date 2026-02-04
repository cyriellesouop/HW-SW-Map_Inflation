`timescale 1ns/1ps

module weight_loader #(
    parameter KERNEL_SIZE  = 16,
    parameter WEIGHT_WIDTH = 8,
    parameter BUS_WIDTH    = 32
)(
    input  clk,
    input  rstn,
    
    // AXI Stream Slave Interface (Weight input)
    input  [BUS_WIDTH - 1 : 0]  s_axis_tdata,
    input                       s_axis_tvalid,
    output                      s_axis_tready,
    
    // Weight output interface
    output [(WEIGHT_WIDTH * KERNEL_SIZE * KERNEL_SIZE) - 1 : 0] weights_out,
    
    // Status outputs
    output loading     // High during when weight are Currently loading
);

    // Local Parameters
    localparam REQUIRED_BITS  = KERNEL_SIZE * KERNEL_SIZE * WEIGHT_WIDTH; // this is the total number of bits required for the entire weigths_out signal
    localparam NUM_TRANSFERS  = (REQUIRED_BITS + BUS_WIDTH - 1) / BUS_WIDTH; // Calculate how many full transfers we need (Rounding Up)
    localparam PADDED_SIZE    = NUM_TRANSFERS * BUS_WIDTH;  // this is the total number of bits send after all the transfer done
    /*localparam LOAD_WEIGHTS = 1'b0;
    localparam IDLE         = 1'b1;*/

    // Internal Signals
    reg [PADDED_SIZE - 1 : 0] weight_storage;
    reg [$clog2(NUM_TRANSFERS) : 0] transfer_counter; //to count the number of transfer done
    //reg state;

    // State definition
    typedef enum {IDLE, LOAD_WEIGHTS} state_t;
    state_t state;

    // FSM State Outputs
    assign loading = (state == LOAD_WEIGHTS); // the loading is high as far as we are in the LOAD WEIGHTs state, otherwise, it goes low.
    assign s_axis_tready = loading;  // Only accept data when loading
    //assign weights_out = weight_storage[REQUIRED_BITS - 1 : 0]; // Slice only the required bits for the output, ignoring the padding at the top
    assign weights_out = weight_storage[PADDED_SIZE - 1 : PADDED_SIZE - REQUIRED_BITS];

    // Weight Loading FSM
    always @(posedge clk) begin
        if (!rstn) begin
            state <= LOAD_WEIGHTS;
            transfer_counter <= 0;
            weight_storage <= {PADDED_SIZE{1'b0}};
        end else begin
            
            case (state)
                LOAD_WEIGHTS: begin
                    if (s_axis_tvalid && s_axis_tready) begin

                        // Shift the whole register and insert new data at the bottom
                        weight_storage <= {weight_storage[PADDED_SIZE-BUS_WIDTH-1 : 0], s_axis_tdata};
                        // Check if all weights loaded
                        if (transfer_counter == NUM_TRANSFERS - 1) begin
                            state <= IDLE;
                            transfer_counter <= 0;
                        end else begin
                            transfer_counter <= transfer_counter + 1;
                        end
                    end
                end
                
                IDLE: begin
                    // Stay idle after loading completes
                    state <= IDLE;
                end
                
                default: state <= LOAD_WEIGHTS;
            endcase
        end
    end

endmodule
