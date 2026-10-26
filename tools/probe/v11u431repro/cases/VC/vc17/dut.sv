// § connOperandNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module sub #(parameter P = 2) (input [7:0] x, output w);
child c(.a(x - P), .b(w));
endmodule
module top(input [7:0] x, output w); sub #(4) u(.x(x), .w(w)); endmodule
