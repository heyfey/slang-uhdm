// § connOperandNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module sub(input [7:0] x, input [2:0] y, output w);
localparam P = 2;
child c(.a(x[y + P]), .b(w));
endmodule
module top(input [7:0] x, input [2:0] y, output w); sub u(.x(x), .y(y), .w(w)); endmodule
