// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  initial $display("%b", later_v);
  logic later_v;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
