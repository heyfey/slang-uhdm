// § connBitSelIdxNonOvParamFold431
module child(input a, output b);
assign b = a;
endmodule
module top(input [15:0] x, output w);
localparam D = 4'd9;
child c(.a(x[D]), .b(w));
endmodule
