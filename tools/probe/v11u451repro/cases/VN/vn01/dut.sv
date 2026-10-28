// § nestedModUndeclReadBare451
module m #(parameter P) (input clk);
  module nest; initial $display("%b", outer_late); endmodule
  nest u_n();
  wire outer_late;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
