// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  initial ++undecl_x;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
