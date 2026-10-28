// § nestedModUndeclReadBare451
module m #(parameter P) (input clk);
  module nest; initial $display("%b", late_v); logic late_v; initial late_v = 1; endmodule
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
