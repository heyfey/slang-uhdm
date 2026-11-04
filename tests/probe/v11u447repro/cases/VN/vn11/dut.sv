// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  initial begin : b static int bv = 1; end
  assign w = bv;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
