// § unitParamPlainEval433v
localparam integer S = -3;
localparam int unsigned T = 7;
module c(input [7:0] a, input [7:0] b); endmodule
module top; logic [7:0] x; c u(.a(x + S), .b(x + T)); endmodule
