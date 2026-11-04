// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  wire w;
  assign w = u_x;
  assign w2 = u_x;
  assign w3 = u_y;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
