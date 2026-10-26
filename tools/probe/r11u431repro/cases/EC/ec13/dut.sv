// § connBitSelIdxNonOvParamFold431
module child(input a, output b);
assign b = a;
endmodule
module top(input [15:0] x, output w);
localparam signed [7:0] S8 = 12;
child c(.a(x[S8]), .b(w));
endmodule
