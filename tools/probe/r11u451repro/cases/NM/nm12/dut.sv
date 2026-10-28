// § nestedModUndeclReadBare451
module m #(parameter P) (input clk);
  module nest;
    initial $display("%b", undecl_w);
    initial $display("%b", undecl_w);
  endmodule
  nest u_n1();
  nest u_n2();
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
