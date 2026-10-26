// § connOpUnitParamFold433
localparam S = 2;
module c(input [7:0] a); endmodule
module top;
  logic [7:0] x [4];
  for (genvar i = 0; i < 2; i++) begin: g
    c u(.a(x[i] + S));
  end
endmodule
