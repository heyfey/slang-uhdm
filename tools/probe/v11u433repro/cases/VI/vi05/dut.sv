// § connIdxUnitParamFold433
localparam S = 2;
module c(input a); endmodule
module top;
  logic [7:0] x;
  for (genvar i = 0; i < 2; i++) begin: g
    c u(.a(x[S]));
  end
endmodule
