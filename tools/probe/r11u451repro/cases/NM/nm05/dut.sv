// § nestedModUndeclReadBare451
module m #(parameter P) (input clk);
  module n1;
    module n2; initial $display("%b", deep_u); endmodule
    n2 u2();
  endmodule
  n1 u1();
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
