// § connOpUnitParamFold433
localparam S = 2;
module c(input [7:0] a); endmodule
module top; logic [7:0] x; c u(.a(x + 4'(S))); endmodule
