// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  initial undecl_y = 1'b1;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
