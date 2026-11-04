// § undefaultedPlaceholderRetry440
module m #(parameter fn1, parameter fn2) (input clk);
  integer f, g;
  initial begin f = $fopen(fn1); g = $fopen(fn2); end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
