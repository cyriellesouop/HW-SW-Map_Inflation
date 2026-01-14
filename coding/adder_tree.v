`timescale 1ns/1ps

module adder_tree 
#(
    parameter KERNEL_SIZE  = 3,
    parameter DATA_WIDTH   = 8,
    parameter WEIGHT_WIDTH = 1
)
(
    input  wire clk,
    input  wire rstn,
    input  wire adder_en,
    input  wire [(DATA_WIDTH+WEIGHT_WIDTH)*KERNEL_SIZE-1:0] adder_dataIn,

    output reg  [(DATA_WIDTH+WEIGHT_WIDTH)+KERNEL_SIZE-1:0] adder_dataOut,
    output reg  adder_done
);

    // ---------------------------------------------------------
    // Local parameters and signals
    // ---------------------------------------------------------
    localparam RESULT_WIDTH = DATA_WIDTH + WEIGHT_WIDTH;

    reg [RESULT_WIDTH-1:0] unpacked_data [0:KERNEL_SIZE-1];
    reg [(RESULT_WIDTH+KERNEL_SIZE)-1:0] accumulator;
    reg [KERNEL_SIZE-1:0] counter;
    reg busy;

    reg [KERNEL_SIZE-1:0] i;

    // ---------------------------------------------------------
    // Unpack the concatenated input bus into an array
    // ---------------------------------------------------------
    always @(*) begin
        for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
            unpacked_data[i] = adder_dataIn[(i+1)*RESULT_WIDTH-1 -: RESULT_WIDTH];
        end
    end

    // ---------------------------------------------------------
    // Sequential addition and done signaling
    // ---------------------------------------------------------
    always @(posedge clk) begin
        if (!rstn) begin
            accumulator   <= 0;
            counter       <= 0;
            busy          <= 0;
            adder_done          <= 0;
            adder_dataOut <= 0;
        end
        else begin
            if (adder_en && !busy) begin
                accumulator <= 0;
                counter     <= 0;
                adder_done        <= 0;
                busy        <= 1;
            end 
            else if (busy) begin
                accumulator <= accumulator + unpacked_data[counter];
                counter <= counter + 1;

                if (counter == KERNEL_SIZE-1) begin
                    adder_dataOut <= accumulator + unpacked_data[counter];
                    adder_done <= 1;
                    busy <= 0;
                end
            end 
            else begin
                adder_done <= 0; 
            end
        end
    end
endmodule

