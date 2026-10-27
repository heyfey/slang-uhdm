// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  assign w = PK;
endmodule
package PK; endpackage
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
