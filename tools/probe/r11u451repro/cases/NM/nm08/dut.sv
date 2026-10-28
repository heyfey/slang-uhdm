// § nestedModUndeclReadBare451
module m #(parameter P) (input clk);
  module nest; logic a, y; always_comb y = a + undecl_r; endmodule
  nest u_n();
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
