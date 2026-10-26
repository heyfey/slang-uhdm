// § unitParamNoOrphan433v
localparam S = 4'sd3;
localparam T = 4'bx01;
localparam int V = -3;
module c(input [7:0] a, input [7:0] b, input [7:0] d); endmodule
module top; logic [7:0] x; c u(.a(x + S), .b(x + T), .d(x + V)); endmodule
