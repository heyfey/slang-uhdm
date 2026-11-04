// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk, output w);
  assign w = undecl_a & undecl_b;
  wire z;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
