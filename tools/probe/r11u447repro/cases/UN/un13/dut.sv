// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  typedef logic [3:0] t_t;
  initial $display("%d", t_t);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
