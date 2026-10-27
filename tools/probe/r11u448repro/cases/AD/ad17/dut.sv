// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  initial wait (undecl_x) $display("w");
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
