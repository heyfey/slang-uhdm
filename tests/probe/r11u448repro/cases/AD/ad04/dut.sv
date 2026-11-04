// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  initial for (int i = 0; i < undecl_n; i++) $display("%d", i);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
