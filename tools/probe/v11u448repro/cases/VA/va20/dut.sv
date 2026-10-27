// § invalidReadDefAdmit448
package pk; parameter int K = 1; endpackage
module m #(parameter P) (input clk);
  import pk::*;
  initial $display("%b %d", undecl_x, K);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
