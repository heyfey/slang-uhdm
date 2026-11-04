// § implicitNetDefLastRef404
module top();
	wire a = 1;
	wire b = 0;
	wire d;
	test mod(a, b, c);
	assign d = c;
endmodule
module test(input a, input b, output c);
	assign c = a | b;
endmodule
