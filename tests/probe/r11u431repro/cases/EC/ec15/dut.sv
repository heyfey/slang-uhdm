// § connBitSelIdxNonOvParamFold431
module child(input a, output b);
assign b = a;
endmodule
module top(input [15:0] x, output w);
localparam E = 2 + 11;
child c(.a(x[E]), .b(w));
endmodule
