// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  initial $display("%b", undecl_x);
endmodule
module n #(parameter Q) (input clk);
  initial $display("%b", undecl_x[1]);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); n n_used(); end endmodule
module top; endmodule
