// § connOperandNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module sub(input [7:0] x, input s, output w);
localparam P = 8'h0f;
child c(.a(s ? x : P), .b(w));
endmodule
module top(input [7:0] x, input s, output w); sub u(.x(x), .s(s), .w(w)); endmodule
