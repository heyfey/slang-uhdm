// § connOperandNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module sub(input [7:0] x, output w);
localparam P = 2;
child c(.a(x[7:4] + P), .b(w));
endmodule
module top(input [7:0] x, output [1:0] w); sub u0(.x(x), .w(w[0])); sub u1(.x(x), .w(w[1])); endmodule
