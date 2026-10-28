// § nestedModUndeclReadBare451
module m #(parameter P) (input clk);
  module nest;
    logic [3:0] q;
    initial begin
      q = undecl_a | undecl_b;
      if (undecl_c) q = 1;
    end
  endmodule
  nest u_n();
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
