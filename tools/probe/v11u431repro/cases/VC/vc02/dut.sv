// § connBitSelIdxNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module sub #(parameter A = 1, parameter B = A + 1) (input [7:0] x, output w);
child c(.a(x[B]), .b(w));
endmodule
module top(input [7:0] x, output [1:0] w);
sub #(.A(4)) u0(.x(x), .w(w[0]));
sub u1(.x(x), .w(w[1]));
endmodule
