// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  initial $display("%b", u_x);
  initial begin : nb int u_x; u_x = 2; end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
