// § undefaultedPlaceholderRetry440
module m #(parameter int unsigned ws [1:0], parameter n) (input clk);
  logic [n-1:0] r;
  initial $display("%d", ws[0]);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
