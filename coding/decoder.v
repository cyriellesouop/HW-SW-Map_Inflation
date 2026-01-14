//======================================================
// Top-level system
// 25-word memory → 25 PEs
// Single 8-bit bus, counter, decoder, write-enable
//======================================================

module top_system (
    input  wire clk,
    input  wire reset
);

    // -------------- Parameters ------------------
    localparam integer NUM_PE = 25;
    localparam integer DATA_WIDTH = 8;
    localparam integer ADDR_WIDTH = 5; // log2(32) > 25

    // -------------- Wires -----------------------
    wire [ADDR_WIDTH-1:0] addr;
    wire [DATA_WIDTH-1:0] mem_data_out;
    wire [NUM_PE-1:0]     we_lines;
    wire [DATA_WIDTH-1:0] pe_out [0:NUM_PE-1];

    //======================================================
    // Address counter 0..24
    //======================================================
    counter_0_to_24 counter_inst (
        .clk(clk),
        .reset(reset),
        .addr(addr)
    );

    //======================================================
    // Memory 25 x 8-bit
    //======================================================
    simple_memory memory_inst (
        .clk(clk),
        .addr(addr),
        .data_out(mem_data_out)
    );

    //======================================================
    // 5-to-25 decoder (one-hot)
    //======================================================
    decoder_5_to_25 decoder_inst (
        .addr(addr),
        .one_hot(we_lines)
    );

    //======================================================
    // Instantiate 25 PEs
    //======================================================
    genvar i;
    generate
        for (i = 0; i < NUM_PE; i = i + 1) begin : PE_ARRAY
            processing_element pe_inst (
                .clk(clk),
                .reset(reset),
                .we(we_lines[i]),          // write enable from decoder
                .data_in(mem_data_out),    // shared 8-bit bus
                .data_out(pe_out[i])
            );
        end
    endgenerate

endmodule



//======================================================
// Counter: counts 0 → 24 then wraps
//======================================================

module counter_0_to_24 (
    input  wire clk,
    input  wire reset,
    output reg  [4:0] addr
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            addr <= 5'd0;
        else if (addr == 5'd24)
            addr <= 5'd0;
        else
            addr <= addr + 1'b1;
    end

endmodule



//======================================================
// Simple memory: 25 x 8-bit ROM or RAM
//======================================================

module simple_memory (
    input  wire clk,
    input  wire [4:0] addr,
    output reg  [7:0] data_out
);

    reg [7:0] mem_array [0:24];

    integer i;

    // Optional: initialize memory contents
    initial begin
        for (i = 0; i < 25; i = i + 1) begin
            mem_array[i] = i; // example data pattern
        end
    end

    always @(posedge clk) begin
        data_out <= mem_array[addr];
    end

endmodule



//======================================================
// 5-to-25 Decoder (one-hot output)
//======================================================

module decoder_5_to_25 (
    input  wire [4:0] addr,
    output reg  [24:0] one_hot
);

    always @(*) begin
        one_hot = 25'd0;
        if (addr < 25)
            one_hot[addr] = 1'b1;
    end

endmodule



//======================================================
// Processing Element
// Stores 8-bit input when WE = 1
//======================================================

module processing_element (
    input  wire clk,
    input  wire reset,
    input  wire we,
    input  wire [7:0] data_in,
    output reg  [7:0] data_out
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            data_out <= 8'd0;
        else if (we)
            data_out <= data_in;
    end

endmodule
