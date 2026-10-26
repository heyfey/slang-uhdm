// § undefaultedPlaceholderRetry440
module m #(parameter n, parameter int ws[n-1:0], parameter int k = 0) (input clk, input [7:0] d, output [7:0] q);
  localparam lw = ws[k];
  assign q[lw-1:0] = d[lw-1:0];
  if (0) always @(negedge clk) $display("%d %p %d", n, ws, lw);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
