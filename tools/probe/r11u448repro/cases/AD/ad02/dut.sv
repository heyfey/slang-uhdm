// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  logic r; always @(posedge clk) if (undecl_x) r = 1; else r = 0;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
