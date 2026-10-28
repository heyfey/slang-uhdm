// § nestedModUndeclReadBare451
module m #(parameter P) (input clk);
  module nest; initial begin $display("%b", undecl_q); $display("%b", undecl_q); end
    initial $display("%b", undecl_r); endmodule
  module nest2; initial $display("%b", undecl_q); endmodule
  nest u_n(); nest2 u_n2();
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
