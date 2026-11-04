// § nestedModUndeclReadBare451
`default_nettype none
module m #(parameter P) (input wire clk);
  module nest; initial $display("%b", undecl_n); endmodule
  nest u_n();
endmodule
`default_nettype wire
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
