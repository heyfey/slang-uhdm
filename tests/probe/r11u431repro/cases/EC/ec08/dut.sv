// § connBitSelIdxNonOvParamFold431
module child(input a, output b);
assign b = a;
endmodule
module top(input [4:0] x, output w);
localparam [2:0] XF = 4;
child c(.a(x[XF]), .b(w));
endmodule
