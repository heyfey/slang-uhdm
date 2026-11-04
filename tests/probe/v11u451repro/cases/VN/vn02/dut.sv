// § nestedModUndeclReadBare451
module m #(parameter P) (input clk);
  module nest; wire y; assign y = undecl_a; endmodule
  nest u_n();
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
