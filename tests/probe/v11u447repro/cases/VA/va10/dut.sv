// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  sub s(.a(imp_a));
  assign w = u_x;
  sub s2(.a(imp_b));
  assign imp_c = u_y;
endmodule
module sub(input a); endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
