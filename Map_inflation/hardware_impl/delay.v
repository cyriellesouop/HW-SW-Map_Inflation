`timescale 1ns/1ps

module delay #(
    parameter LATENCY = 1,
    parameter WIDTH   = 1
)(
    input              clk,
    input              rstn,     // synchronous active-low reset
    input   [WIDTH-1:0] dataIn,
    output [WIDTH-1:0] dataOut
);

generate
    if (LATENCY == 0) begin : gen_bypass
        // No delay
        assign dataOut = dataIn;

    end else begin : gen_pipeline
        reg [WIDTH-1:0] pipe [0:LATENCY-1];
        reg [LATENCY : 0 ] i;

        always @(posedge clk) begin
            if (!rstn) begin
                for (i = 0; i < LATENCY; i = i + 1)
                    pipe[i] <= {WIDTH{1'b0}};
            end else begin
                pipe[0] <= dataIn;
                for (i = 1; i < LATENCY; i = i + 1)
                    pipe[i] <= pipe[i-1]; // // Shift the pipeline
            end
        end

        assign dataOut = pipe[LATENCY-1];
    end
endgenerate

endmodule

