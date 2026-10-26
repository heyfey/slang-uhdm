// § connBitSelIdxNonOvParamFold431
module child(input a, output b);
assign b = a;
endmodule
module top(input [15:0] x, output w);
localparam logic signed [7:0] LS = 6;
child c(.a(x[LS]), .b(w));
endmodule
