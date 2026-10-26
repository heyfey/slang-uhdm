// § connIdxUnitParamFold433
localparam S = 2;
module c(input [1:0] a); endmodule
module top; logic [7:0] x; c u(.a(x[S:0])); endmodule
