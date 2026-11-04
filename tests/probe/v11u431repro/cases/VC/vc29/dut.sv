// § connOperandNonOvParamFold431 (an indexed part-select base over a signal and a parameter)
module child(input [3:0] a, output b);
assign b = a[0];
endmodule
module sub(input [7:0] x, input [1:0] y, output w);
localparam P = 2;
child c(.a(x[y + P +: 4]), .b(w));
endmodule
module top(input [7:0] x, input [1:0] y, output w); sub u(.x(x), .y(y), .w(w)); endmodule
