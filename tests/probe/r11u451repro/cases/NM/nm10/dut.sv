// § nestedModUndeclReadBare451
module m #(parameter P) (input clk);
  module nest; initial $display("%b", undecl_v); endmodule
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
