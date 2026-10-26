// § connBitSelIdxNonOvParamFold431
module child(input [1:0] a, output b);
assign b = a[0];
endmodule
module sub(input [4:0] x, output w);
localparam XF = 4;
child c(.a(x[XF:XF-1]), .b(w));
endmodule
module top(input [4:0] x, output w);
sub u(.x(x), .w(w));
endmodule
