// § connBitSelIdxNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
localparam UP = 3;
module sub(input [7:0] x, output w);
localparam P = UP;
child c(.a(x[P]), .b(w));
endmodule
module top(input [7:0] x, output w); sub u(.x(x), .w(w)); endmodule
