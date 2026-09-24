module dut (input  a, output b, output c, output d);
	assign b = $unsigned(a);
	assign c = $unsigned(a);
	assign d = $unsigned(a);
endmodule
