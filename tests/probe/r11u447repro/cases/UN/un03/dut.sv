// § undeclaredReadImplicitNet447
module m #(parameter P) (input clk);
  always @(negedge clk) $display("%b", undecl_y);
  assign imp_w = clk;
  always @(negedge clk) $display("%b", undecl_x, undecl_y);
  wire late_w;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
