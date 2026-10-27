// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  if (1) begin : g localparam L = 1; end
  assign w = L;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
