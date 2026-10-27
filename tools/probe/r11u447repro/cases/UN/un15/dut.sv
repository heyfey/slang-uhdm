// § undeclaredReadImplicitNet447
module ch(input a); endmodule
module m #(parameter P) (input clk);
  initial $display("%b", imp_a);
  ch u1(.a(imp_a));
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
