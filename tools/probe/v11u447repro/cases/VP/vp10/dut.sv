// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  if (1) begin : g initial $display("%b", u_g); end
  initial $display("%b", u_g);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
