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
    output m_axis_tvalid,
    output [DATA_WIDTH-1:0] m_axis_tdata,
    input  m_axis_tready
);

    reg [$clog2(KERNEL_SIZE)-1:0] count;

    // --- 1. Unpack flattened data bus ---
    wire [DATA_WIDTH-1:0] unpacked_s_data [0:KERNEL_SIZE-1];
    generate
        for (genvar g = 0; g < KERNEL_SIZE; g = g + 1) begin
            assign unpacked_s_data[g] = s_axis_tdata[g*DATA_WIDTH +: DATA_WIDTH];
        end
    endgenerate

    // --- 2. Combinational Selection (Multiplexing) ---
    // We select the data and valid signal based on the current counter
    assign m_axis_tdata  = unpacked_s_data[count];
    assign m_axis_tvalid = s_axis_tvalid[count];

    // --- 3. Backpressure (Ready Routing) ---
    // Only the currently selected adder receives the 'tready' signal
    assign s_axis_tready = (m_axis_tready) ? (1'b1 << count) : {KERNEL_SIZE{1'b0}};

    // --- 4. Counter Update Logic ---
    always @(posedge clk) begin
        if (!rstn) begin
            count <= 0;
        end else begin
            // Rule 1: Successful Transfer 
            // If valid and ready are both high, the data is "read". Move to next.
            if (m_axis_tvalid && m_axis_tready) begin
                if (count == KERNEL_SIZE - 1) count <= 0;
                else count <= count + 1;
            end
            
            // Rule 2: Skip if Empty
            // If the current adder is not valid, we don't wait. Move to next.
            else if (!m_axis_tvalid) begin
                if (count == KERNEL_SIZE - 1) count <= 0;
                else count <= count + 1;
            end
            
            // Otherwise: We have valid data but the master isn't ready. 
            // We MUST stay on this 'count' to maintain AXI protocol.
        end
    end

endmodule
