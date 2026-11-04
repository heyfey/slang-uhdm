// § connBitSelIdxNonOvParamFold431
module child(input a, output b);
assign b = a;
endmodule
module sub #(parameter XF = 4) (input [4:0] x, output w);
child c(.a(x[XF]), .b(w));
endmodule
module top(input [4:0] x, output w);
sub u(.x(x), .w(w));
endmodule
