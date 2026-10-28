// § nestedModUndeclReadBare451
module m #(parameter P) (input clk);
  module nest; initial $display("%b", late_p); parameter late_p = 1; endmodule
  nest u_n();
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
