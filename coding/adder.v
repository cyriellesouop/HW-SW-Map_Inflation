`timescale 1ns/1ps

module adder
#( parameter N = 4)
(
	input [N-1:0] a,
	input [N-1:0] b,
	output [N-1:0] s,
	output c
);

	wire [N-1:0] carry;

	assign c = carry [N-1];

	genvar i;
	generate

		for(i= 0; i < N; i = i+1)
		begin
			if(i == 0) // the firdt adder is a half adder
			begin
			       half_adder HA(
			       	.a(a[i]),
				.b(b[i]),
				.sum(s[i]),
				.carry(carry[i])
			       );	
			end 
			else
			begin

				full_adder FA(
					.a(a[i]),
					.b(b[i]),
					.carry_in(carry[i-1]),
					.sum(s[i]),
					.carry_out(carry[i])
				);


			end 


		end
	endgenerate

endmodule
