// § undefaultedPlaceholderRetry440
module m #(parameter type T = logic, parameter fn) (input clk);
  T x;
  integer f;
  initial f = $fopen(fn);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
