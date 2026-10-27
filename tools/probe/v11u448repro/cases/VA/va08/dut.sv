// § invalidReadDefAdmit448
module other; endmodule
module m #(parameter P) (input clk);
  initial $display("%b", other);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
