// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  initial begin : lbl end
  initial $display("%b", lbl);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
