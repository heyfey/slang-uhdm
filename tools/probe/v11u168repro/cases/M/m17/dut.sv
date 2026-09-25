// § ppOutputCol166
`define ML(y, x) \
	assign y = \
		x ^ 1'b1;
module top(input logic a, output logic y);
	`ML(y, a)
endmodule
