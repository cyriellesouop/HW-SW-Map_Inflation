`timescale 1ns/1ps

module register #(
    parameter WIDTH = 8
)(
    input                  clk,
    input                  rst,
    input                  en,
    input  [WIDTH - 1 : 0] input_data,
    output [WIDTH - 1 : 0] output_data
);

    reg [WIDTH - 1 : 0] data_reg;
    
    always @(posedge clk) begin
        if (rst) begin
            data_reg <= {WIDTH{1'b0}};
        end else begin
            if (en) begin
                data_reg <= input_data;
            end
        end
    end
    
    assign output_data = data_reg;

endmodule
