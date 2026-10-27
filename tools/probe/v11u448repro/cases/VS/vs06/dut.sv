// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  logic r;
  always_comb begin #1 r = 1'b1; end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
