// § nestedModUndeclReadBare451
module m #(parameter P) (input clk);
  module nest; initial $display("%b", undecl_s); endmodule
  nest u_n();
  initial $display("%b", undecl_t);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
