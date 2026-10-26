// § undefaultedPlaceholderRetry440
module m #(parameter fn) (input clk);
  integer f;
  initial f = $fopen(fn, "w");
endmodule
