`timescale 1ns/1ps

module crossbar
#(
    parameter KERNEL_SIZE = 3,
    parameter DATA_WIDTH  = 18
)(
    input clk,
    input rstn,

    // Slave Interfaces (From Adder Trees)
    input  [KERNEL_SIZE-1:0] s_axis_tvalid,
    input  [DATA_WIDTH*KERNEL_SIZE-1:0] s_axis_tdata,
    output [KERNEL_SIZE-1:0] s_axis_tready,

    // Master Interface (To Output Module)
    output reg m_axis_tvalid,
    output reg [DATA_WIDTH-1:0] m_axis_tdata,
    input  m_axis_tready
);

    reg [DATA_WIDTH-1:0] reg_s_tdata  [0:KERNEL_SIZE-1];
    reg [KERNEL_SIZE-1:0] reg_s_tvalid;
    reg [$clog2(KERNEL_SIZE)-1:0] count;
    reg start_counter;
    
        
    // We look at the REGISTERED signals to make decisions
    wire current_reg_valid = reg_s_tvalid[count];
    wire [DATA_WIDTH-1:0] current_reg_data = reg_s_tdata[count];
    wire can_update_inputs = (m_axis_tready || !m_axis_tvalid); // We only accept new data from adders when the crossbar is ready to move

    genvar i;
    generate
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin 
            always @(posedge clk) begin
                if (!rstn) begin
                    reg_s_tvalid[i] <= 1'b0;
                    reg_s_tdata[i]  <= {DATA_WIDTH{1'b0}};
                end else if (can_update_inputs) begin
                    // Buffer the incoming signals
                    reg_s_tvalid[i] <= s_axis_tvalid[i];
                    reg_s_tdata[i]  <= s_axis_tdata[i*DATA_WIDTH +: DATA_WIDTH];
                end
            end
            // Ready is only high if we can update the registers
            assign s_axis_tready[i] = can_update_inputs;
        end
    endgenerate


    // Selection & Counter Logic 
    always @(posedge clk) begin
        if (!rstn) begin
            count <= 0;
            m_axis_tvalid <= 1'b0;
            m_axis_tdata  <= {DATA_WIDTH{1'b0}};
            start_counter   <= 1'b0; // Reset start flag
        end else begin
            if (can_update_inputs) begin
                if (current_reg_valid) begin
                    // Successful Selection: Capture data to output
                    start_counter   <= 1'b1;
                    m_axis_tdata  <= current_reg_data;
                    m_axis_tvalid <= 1'b1;
                    
                    // Increment counter to move to next adder
                    if (count == KERNEL_SIZE - 1) count <= 0;
                    else count <= count + 1;
                end 
                else if (start_counter) begin
                    // Skip Logic: Current registered slot is empty
                    m_axis_tvalid <= 1'b0;
                    if (count == KERNEL_SIZE - 1) count <= 0;
                    else count <= count + 1;
                end
                else begin               
                   // Before starting, we stay at count 0.
                   // This forces Row 0 to be the first row ever processed.
                   m_axis_tvalid <= 1'b0;
                   count <= 0;               
                end
            end
        end
    end

endmodule
