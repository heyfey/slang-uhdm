// § invalidReadDefAdmit448
`define RD undecl_x
module m #(parameter P) (input clk);
  initial $display("%b", `RD);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
