// § undefaultedPlaceholderRetry440
module m #(parameter n, parameter int ws [n-1:0], parameter fn) (input clk);
  integer f;
  initial f = $fopen(fn, "w");
  initial $display("%0d", ws[0]);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
