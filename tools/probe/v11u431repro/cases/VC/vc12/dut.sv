// § connBitSelIdxNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module sub(input [7:0] x, output w);
localparam shortint P = 3;
localparam longint Q = 1;
child c(.a(x[P] ^ x[Q]), .b(w));
endmodule
module top(input [7:0] x, output w); sub u(.x(x), .w(w)); endmodule
