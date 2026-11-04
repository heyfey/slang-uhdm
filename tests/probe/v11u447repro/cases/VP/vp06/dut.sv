// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  initial $display("%b", u_b);
  sub s(.a(imp_a));
  initial $display("%b", u_a);
  initial $display("%b", u_b);
endmodule
module sub(input a); endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
