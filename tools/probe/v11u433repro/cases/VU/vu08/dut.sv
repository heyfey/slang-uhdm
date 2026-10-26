// § connOpUnitParamFold433
localparam S = 2;
module c(input [7:0] a); endmodule
module top; logic [7:0] x, y; c u(.a((x & S) | (y << S))); endmodule
