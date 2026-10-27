// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk, output [3:0] w);
  assign w = {undecl_a, 3'b0};
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
