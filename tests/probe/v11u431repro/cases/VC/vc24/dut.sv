// § connOperandNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module sub #(parameter A = 1, parameter B = 2) (input [7:0] x, output w);
child c(.a((x & A) | B), .b(w));
endmodule
module top(input [7:0] x, output [1:0] w);
sub #(.A(3)) u0(.x(x), .w(w[0]));
sub #(.B(5)) u1(.x(x), .w(w[1]));
endmodule
