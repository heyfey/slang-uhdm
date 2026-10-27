// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  sequence s; clk ##1 u_s; endsequence
  assign w = clk;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
