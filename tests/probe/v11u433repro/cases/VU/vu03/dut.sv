// § connOpUnitParamFold433
localparam byte S = 3;
module c(input [7:0] a); endmodule
module top; logic [7:0] x; c u(.a(x + S)); endmodule
