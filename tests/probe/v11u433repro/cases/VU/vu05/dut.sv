// § connOpUnitParamFold433
localparam S = 1'b1;
localparam T = 'hF;
module c(input [7:0] a, input [7:0] b); endmodule
module top; logic [7:0] x; c u(.a(x & S), .b(x | T)); endmodule
