// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  for (genvar i = 0; i < 2; i++) begin : g assign w = u_g; end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
