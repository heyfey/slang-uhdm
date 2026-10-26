// § connBitSelIdxNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module sub #(parameter P = 1) (input [7:0] x, output w);
child c(.a(x[P]), .b(w));
endmodule
module top(input [7:0] x, output w);
sub u(.x(x), .w(w));
defparam u.P = 5;
endmodule
