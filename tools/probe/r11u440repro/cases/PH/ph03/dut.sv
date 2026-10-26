// § undefaultedPlaceholderRetry440
module m #(parameter fn, parameter w) (input clk);
  integer f;
  initial f = $fopen(fn);
  logic [w-1:0] r;
endmodule
module top; endmodule
