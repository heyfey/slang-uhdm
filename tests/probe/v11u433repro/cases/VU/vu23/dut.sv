// § unitParamPlainEval433v
localparam S = 3000000000;
module c(input [63:0] a, output [63:0] y); assign y = a; endmodule
module top(input [63:0] x, output [63:0] y); c u(.a(x + S), .y(y)); endmodule
