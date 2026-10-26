// § connOperandNonOvParamFold431 (an instance array)
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module sub(input [7:0] x, output [1:0] w);
localparam P = 3;
child c[1:0] (.a({x[P +: 4], x[P +: 4]} >> P), .b(w));
endmodule
module top(input [7:0] x, output [1:0] w); sub u(.x(x), .w(w)); endmodule
