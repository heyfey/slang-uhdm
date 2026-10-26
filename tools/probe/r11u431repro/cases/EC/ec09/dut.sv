// § connBitSelIdxNonOvParamFold431
module child(input a, output b);
assign b = a;
endmodule
module top(input [4:0] x, output w);
child c(.a(x[4]), .b(w));
endmodule
