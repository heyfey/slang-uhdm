// § connBitSelIdxNonOvParamFold431
module child(input a, output b);
assign b = a;
endmodule
module sub(input [4:0] x, output w);
localparam XF = 3;
child c(.a(x[XF+1]), .b(w));
endmodule
module top(input [4:0] x, output w);
sub u(.x(x), .w(w));
endmodule
