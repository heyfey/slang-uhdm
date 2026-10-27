// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  struct packed { logic fld; } s;
  initial $display("%b", fld);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
