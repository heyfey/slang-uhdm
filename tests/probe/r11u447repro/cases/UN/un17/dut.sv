// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  initial begin #1 $display("%b", undecl_x); end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
