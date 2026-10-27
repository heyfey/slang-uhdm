// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  initial begin $display("%b", undecl_x); $display("%b", undecl_x + undecl_z); end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
