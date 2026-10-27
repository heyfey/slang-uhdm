// § undeclaredReadImplicitNet447
module ch(input a); endmodule
module m #(parameter P) (input clk);
  ch u1(.a(imp_a));
  always @(negedge clk) $display("%b", undecl_x);
  ch u2(.a(imp_b));
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
