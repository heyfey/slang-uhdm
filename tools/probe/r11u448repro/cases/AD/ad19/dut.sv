// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  initial $display("%b", undecl_x[0]);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
