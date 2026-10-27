// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  initial begin : b int undecl_x; undecl_x = 1; end
  initial $display("%b", undecl_x);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
