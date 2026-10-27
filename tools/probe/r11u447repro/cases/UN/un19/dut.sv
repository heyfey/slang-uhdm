// § undeclaredReadImplicitNet447
module m #(parameter P = 2, parameter Q) (input clk);
  initial begin : nb $display("%b", undecl_x); end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
