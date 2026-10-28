// § nestedModUndeclReadBare451
module m #(parameter P) (input clk);
  logic outer_v;
  module nest; initial $display("%b", outer_v, undecl_q); endmodule
  nest u_n();
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
