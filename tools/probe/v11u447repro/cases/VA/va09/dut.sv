// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w1, w2;
  assign w1 = u_x;
  assign w2 = u_x;
  sub s(.a(imp_a));
endmodule
module sub(input a); endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
