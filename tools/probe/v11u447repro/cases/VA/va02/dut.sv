// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w1, w2;
  assign w1 = u_b;
  wire w3 = u_a;
  assign w2 = u_c;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
