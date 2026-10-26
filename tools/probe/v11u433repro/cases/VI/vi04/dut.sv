// § connIdxUnitParamFold433
localparam S = 4'd2;
localparam T = 'h3;
module c(input a, input b); endmodule
module top; logic [7:0] x; c u(.a(x[S]), .b(x[T])); endmodule
