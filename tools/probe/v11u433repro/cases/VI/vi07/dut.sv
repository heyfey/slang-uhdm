// § connIdxUnitParamFold433
localparam S = 2;
module c(input a); endmodule
module top; logic [7:0] x; c u(.a(x[S])); c u2(x[S]); endmodule
