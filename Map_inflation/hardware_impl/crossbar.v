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
    reg [$clog2(KERNEL_SIZE)-1:0] count;  // counter to loop into the number of row (KERNEL_SIZE rows)
    reg start_counter;  // state register to decide when the crossbar start reading data from the upstream (data)
    
    // Combinational signals
    wire output_fire = m_axis_tvalid && m_axis_tready;
    wire can_update = m_axis_tready || !m_axis_tvalid;
    wire all_slots_valid = &reg_s_tvalid;

    // Next count value (for better timing)
    wire [$clog2(KERNEL_SIZE)-1:0] count_next = (count == KERNEL_SIZE - 1) ? 'd0 : count + 1'd1;
        
   //1. buffering stage 
    genvar i;
    generate
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin 
            // the counter is pointing a the buffer slot i,  the master is ready to accept data, the crossbar is currently outputting valid data
	    wire slot_selected = (count == i);
            wire slot_being_read = slot_selected && output_fire;
           // A row is ready to accept new data if: Its internal register(buffer) is currently empty OR the master is consuming it right now.
	    assign s_axis_tready[i] = !reg_s_tvalid[i] || slot_being_read ; //Allows the adder tree to send new data if the buffer is being emptied this cycle

            always @(posedge clk) begin
                if (!rstn) begin
                    reg_s_tvalid[i] <= 1'b0;
                    reg_s_tdata[i]  <= {DATA_WIDTH{1'b0}};
                end else begin
                    if (s_axis_tready[i] && s_axis_tvalid[i]) begin
                        // Load new data from the Adder Tree into this specific slot
                        reg_s_tvalid[i] <= 1'b1;
                        reg_s_tdata[i]  <= s_axis_tdata[i*DATA_WIDTH +: DATA_WIDTH];
                    end else if (slot_being_read) begin
                        reg_s_tvalid[i] <= 1'b0; // If Data in the slot is  consumed by the master but no new data is arriving
                    end
                end
            end
        end
    endgenerate

    // 2.  Sequence Logic 
    always @(posedge clk) begin
        if (!rstn) begin
            count <= 'd0;
            start_counter<= 1'b0;
            m_axis_tvalid <= 1'b0;
            m_axis_tdata  <= {DATA_WIDTH{1'b0}};
        end else begin
            // Standard AXI-Stream Flow Control
	    // only accept new data from adders when the downstream(master) is ready to consume data or
	    // there is  no valid transaction happening  (output data data invalid)
            if (can_update) begin 
                
                if (!start_counter) begin
                    //  start condition :  Wait until every row(slots) has at least one value
                    if (&reg_s_tvalid) begin 
                        start_counter   <= 1'b1;
                        m_axis_tdata  <= reg_s_tdata[0]; // Start with Row 0
                        m_axis_tvalid <= 1'b1;
                        count         <= 'd1; // Prepare to look at Row 1
                    end else begin
                        m_axis_tvalid <= 1'b0;
                        count         <= 0; // Stay parked at Row 0
                    end
                end 
                else begin
                    // Then, Cycle through rows in Round-Robin
                    if (reg_s_tvalid[count]) begin    // current slot has data
                        m_axis_tdata  <= reg_s_tdata[count];  // output data from current slot
                        m_axis_tvalid <= 1'b1;  // asser valid
                        count <= count_next;  // move to the next slot
                    end else begin
                        // If the expected row isn't ready,  the counter stays pointing at the same slot,
			// This maintains strict round-robin order
                        m_axis_tvalid <= 1'b0;
                    end
                end
            end
        end
    end

endmodule
