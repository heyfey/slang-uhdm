// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  wire n;
  initial n = 1'b1;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
