`timescale 1ns/1ps

module half_adder(
    input a,
    input b,
    output sum,
    output carry
);

    assign sum = (a && ~b) || (~a && b) ;
    assign carry = a && b; 

endmodule
