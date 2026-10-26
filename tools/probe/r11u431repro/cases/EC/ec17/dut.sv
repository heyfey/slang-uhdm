// § connBitSelIdxNonOvParamFold431
module child(input a, output b);
assign b = a;
endmodule
module sub #(parameter P = 3) (input [15:0] x, output w);
child c(.a(x[P]), .b(w));
endmodule
module top(input [15:0] x, output [1:0] w);
sub #(.P(5)) u0(.x(x), .w(w[0]));
sub u1(.x(x), .w(w[1]));
endmodule
