// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  initial begin : b int q; q = 1; end
  initial $display("%d", q);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
