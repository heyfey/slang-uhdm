// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  initial begin : b enum {UX, UY} e; e = UX; end
  initial $display("%d", UY);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
