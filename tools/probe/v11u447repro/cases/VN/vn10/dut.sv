// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  if (1) begin : g enum {GX} ge; end
  assign w = GX;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
