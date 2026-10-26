// § connBitSelIdxNonOvParamFold431
module child(input a, output b);
assign b = a;
endmodule
module top(input [15:0] x, output w);
localparam signed S = 3;
child c(.a(x[S]), .b(w));
endmodule
