// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  initial $display("%b", undecl_x.y);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
