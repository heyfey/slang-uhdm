// § connIdxUnitParamFold433
localparam S = 2;
module c(input a); endmodule
module top; logic [7:0] x [4]; c u(.a(x[S][1])); endmodule
