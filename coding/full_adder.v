`timescale 1ns/1ps

module full_adder(
    input a,
    input b,
    input carry_in,
    output sum,
    output carry_out
);

	wire sum1;
	wire carry1;
	wire carry2;

	half_adder half1 (.a(a), .b(b), .sum(sum1), .carry(carry1));

	half_adder half2 (.a(sum1), .b(carry_in), .sum(sum), .carry(carry2));

	assign carry_out = carry1 | carry2;

endmodule
