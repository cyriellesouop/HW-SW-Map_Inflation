`timescale 1ns/1ps

module tb_adder;

	parameter N = 6;

	reg [N-1:0] a;
	reg [N-1:0] b;
	wire [N-1:0] s;
	wire c;

	

	adder #(.N(N)) DUT (
		.a(a),
		.b(b),
		.s(s),
		.c(c)
       	);


        initial begin
		a = 5;
		b = 7;
		#10;
		a = 0;
		b = 15;
		#10;
		a = 'bx;
		b = 2;
		#10;
		a = 6;
		b = 'bz;
		#10;
		a = 'bx;
		b = 'bz;

	end

	initial begin
		$monitor("a %b , b %b =   s %b |  c %b ", a, b, s , c);


	end
endmodule
