// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  logic r; always @(posedge clk) r = clk ? undecl_x : 1'b0;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
