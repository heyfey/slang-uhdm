// § connBitSelIdxNonOvParamFold431
module child(input a, output b);
assign b = a;
endmodule
module top(input [4:0] x, output w);
localparam XF = 4;
wire t = x[XF];
child c(.a(t), .b(w));
endmodule
