// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  assign w = m;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
