// § unitParamPlainEval433v
localparam S = 3000000000;
localparam T = 2 * 3 + 1;
module c(input [63:0] a, input [7:0] b); endmodule
module top; logic [63:0] x; c u(.a(x + S), .b(x[7:0] + T)); endmodule
