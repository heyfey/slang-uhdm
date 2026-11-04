// § connBitSelIdxNonOvParamFold431
module child(input a, output b);
assign b = a;
endmodule
module sub(input [4:0] x, output w);
localparam XF = 4;
logic [4:0] y;
assign y = x;
child c(.a(y[XF]), .b(w));
endmodule
module top(input [4:0] x, output w);
sub u(.x(x), .w(w));
endmodule
