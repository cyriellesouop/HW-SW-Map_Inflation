`timescale 1ns/1ps

module axim_reg
#(
    parameter ADDRESS_WIDTH = 32,
    parameter DATA_WIDTH = 32
)
(
    input  clk,
    input  rstn,

    // Write Address Channel
    input [ADDRESS_WIDTH-1:0] s_axi_awaddr,
    input                     s_axi_awvalid,
    output reg                s_axi_awready,

    // Write Data Channel
    input  [DATA_WIDTH-1:0]   s_axi_wdata,
    input                     s_axi_wvalid,
    output reg                s_axi_wready,

    // Write Response Channel
    output reg [1:0]          s_axi_bresp,
    output reg                s_axi_bvalid,
    input                     s_axi_bready,

    // Output Register
    output reg [DATA_WIDTH-1:0] output_reg
);

    // State definition
    typedef enum {IDLE, WR_DATA, WR_RESP} state_t;

   // reg [1:0] state;
    state_t state;
    reg [DATA_WIDTH-1:0] tmp_data;
    reg load_en;
    reg [ADDRESS_WIDTH-1:0] waddr;

    // control logic : FSM State Transitions
    always @(posedge clk) begin
        if (!rstn) begin
            state    <= IDLE;
        end
       	else begin
            case (state)
                IDLE: begin
                    // Wait for the master to start a write address transaction
                    if (s_axi_awvalid) 
                        state <= WR_DATA;
                end

                WR_DATA: begin
                    // Wait for valid data from the master
                    if (s_axi_wvalid)
                        state <= WR_RESP;
                end

                WR_RESP: begin
                    // Wait for the master to acknowledge the response (BREADY)
                    if (s_axi_bready)
                        state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

    // dataflow logic
    always @(*) begin
        // Default values
        s_axi_awready  = 1'b0;
        s_axi_wready   = 1'b0;
        s_axi_bvalid   = 1'b0;
	s_axi_bresp   = 2'b00;
        load_en  = 1'b0;
       // tmp_data = {DATA_WIDTH{1'b0}};
        tmp_data = s_axi_wdata;

        case (state)
            IDLE: begin
		s_axi_wready   = 1'b0;
                s_axi_awready = 1'b1;
	       	s_axi_bvalid   = 1'b0;
		waddr = s_axi_awaddr;
            end
            WR_DATA: begin
                s_axi_wready = 1'b1;
	        s_axi_awready  = 1'b0;
               // tmp_data = s_axi_wdata;
                // Only trigger the load enable if data is valid
                if (s_axi_wvalid && (waddr == 0) ) load_en = 1'b1;
            end

            WR_RESP: begin
		s_axi_wready = 1'b0;
                s_axi_bvalid = 1'b1;
		if(waddr == 0) 
		   s_axi_bresp = 2'b00;
		else
		  s_axi_bresp = 2'b10;
            end
        endcase
    end

    // ---write the output in a register ---
    always @(posedge clk) begin
        if (!rstn)
            output_reg <= {DATA_WIDTH{1'b0}};
        else if (load_en)
            output_reg <= tmp_data;
    end
endmodule
