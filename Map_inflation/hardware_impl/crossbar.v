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
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin : buffer_gen
            // A row is ready to accept new data if:
            // Its internal register is currently empty OR the master is consuming it right now.
            wire line_being_emptied = (count == i) && m_axis_tready && m_axis_tvalid;
            assign s_axis_tready[i] = !reg_s_tvalid[i] || line_being_emptied;

            always @(posedge clk) begin
                if (!rstn) begin
                    reg_s_tvalid[i] <= 1'b0;
                    reg_s_tdata[i]  <= {DATA_WIDTH{1'b0}};
                end else begin
                    if (s_axis_tready[i]) begin
                        // Load new data from the Adder Tree into this specific slot
                        reg_s_tvalid[i] <= s_axis_tvalid[i];
                        reg_s_tdata[i]  <= s_axis_tdata[i*DATA_WIDTH +: DATA_WIDTH];
                    end else if (line_being_emptied) begin
                        // If we are emptying the slot but no new data is arriving
                        reg_s_tvalid[i] <= 1'b0;
                    end
                end
            end
        end
    endgenerate

    // --- 2. Master Output & Sequence Logic ---
    always @(posedge clk) begin
        if (!rstn) begin
            count <= 0;
            start_counter<= 1'b0;
            m_axis_tvalid <= 1'b0;
            m_axis_tdata  <= 0;
        end else begin
            // Standard AXI-Stream Flow Control
            if (m_axis_tready || !m_axis_tvalid) begin
                
                if (!start_counter) begin
                    // START CONDITION: Wait until EVERY row has at least one value
                    if (&reg_s_tvalid) begin 
                        start_counter   <= 1'b1;
                        m_axis_tdata  <= reg_s_tdata[0]; // Start with Row 0
                        m_axis_tvalid <= 1'b1;
                        count         <= 1; // Prepare to look at Row 1
                    end else begin
                        m_axis_tvalid <= 1'b0;
                        count         <= 0; // Stay parked at Row 0
                    end
                end 
                else begin
                    // RUNNING STATE: Cycle through rows in Round-Robin
                    if (reg_s_tvalid[count]) begin
                        m_axis_tdata  <= reg_s_tdata[count];
                        m_axis_tvalid <= 1'b1;
                        count <= (count == KERNEL_SIZE - 1) ? 0 : count + 1;
                    end else begin
                        // If the expected row isn't ready, we stay high-valid but wait,
                        // OR we can pulse valid low. Staying put ensures row order.
                        m_axis_tvalid <= 1'b0;
                    end
                end
            end
        end
    end

endmodule
