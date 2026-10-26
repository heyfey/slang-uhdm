// § connOperandNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module top(input [7:0] x, output w);
localparam XF = 4;
child c(.a(x[0] ? XF : 3), .b(w));
endmodule
