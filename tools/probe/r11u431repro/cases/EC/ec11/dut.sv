// § connOperandNonOvParamFold431
module child(input [4:0] a, output b);
assign b = a[0];
endmodule
module top(input [4:0] x, output w);
localparam XF = 4;
child c(.a(x ^ XF), .b(w));
endmodule
