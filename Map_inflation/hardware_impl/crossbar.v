`timescale 1ns/1ps

module crossbar
#(
    parameter KERNEL_SIZE = 3,
    parameter DATA_WIDTH  = 18
)(
    input clk,
    input rstn,

    // Slave interface from adder trees
    input  [KERNEL_SIZE-1:0] s_axis_tvalid,
    input  [DATA_WIDTH*KERNEL_SIZE-1:0] s_axis_tdata,
    output [KERNEL_SIZE-1:0] s_axis_tready,

    // Master Interface to output the results  (* IOB = "TRUE" *) 
   output reg m_axis_tvalid,
  output reg [DATA_WIDTH-1:0] m_axis_tdata,
    input m_axis_tready
);

    localparam COUNT_WIDTH = $clog2(KERNEL_SIZE);
    reg [DATA_WIDTH-1:0] reg_s_tdata [0:KERNEL_SIZE-1];
    reg [KERNEL_SIZE-1:0] reg_s_tvalid;
    reg [$clog2(KERNEL_SIZE)-1:0] count;

    wire output_fire = m_axis_tvalid && m_axis_tready;
    wire can_update = m_axis_tready || !m_axis_tvalid;

    // Pre-compute next count to avoids long combinational chain in the always block
    wire [COUNT_WIDTH-1:0] count_next = (count == KERNEL_SIZE[COUNT_WIDTH-1:0] - 1'b1) ? {COUNT_WIDTH{1'b0}} : count + 1'b1;
   // wire [$clog2(KERNEL_SIZE)-1:0] count_next = (count == KERNEL_SIZE - 1) ? 'd0 : count + 1'd1;

    // 1. slots buffer stage:  Each slot independently accepts new data from its adder-tree fifo row
    genvar i;
    generate
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin 
            wire slot_selected = (count == i[$clog2(KERNEL_SIZE)-1:0]);
            wire slot_being_read = slot_selected && output_fire;
            assign s_axis_tready[i] = !reg_s_tvalid[i] || slot_being_read; // Accept new data if slot is empty or being drained right now

            always @(posedge clk) begin
                if (!rstn) begin
                    reg_s_tvalid[i] <= 1'b0;
                    reg_s_tdata[i] <= {DATA_WIDTH{1'b0}};
                end else begin
                    if (s_axis_tready[i] && s_axis_tvalid[i]) begin
                        reg_s_tvalid[i] <= 1'b1; // New data arriving from adder tree row i
                        reg_s_tdata[i] <= s_axis_tdata[i*DATA_WIDTH +: DATA_WIDTH];
                    end else if (slot_being_read) begin
                        reg_s_tvalid[i] <= 1'b0; // Slot consumed by the master, no new data this cycle
                    end
                end
            end
        end
    endgenerate

    always @(posedge clk) begin
        if (!rstn) begin
            count <= 'd0;
            m_axis_tvalid <= 1'b0;
            m_axis_tdata <= {DATA_WIDTH{1'b0}};
        end else begin
            if (can_update) begin
                if (reg_s_tvalid[count]) begin
                    // Current slot is ready
                    m_axis_tdata <= reg_s_tdata[count]; 
                    m_axis_tvalid <= 1'b1;      // current slow has a valid data
                    count <= count_next; // We increment the counter
                end else begin
                    m_axis_tvalid <= 1'b0; //current slot is not yet valid
                end
            end
        end
    end

endmodule
