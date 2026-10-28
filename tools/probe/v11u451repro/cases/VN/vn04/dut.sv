// § nestedModUndeclReadBare451
module m #(parameter P) (input clk);
  typedef int tt;
  module nest; initial $display("%b", tt); endmodule
  nest u_n();
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
