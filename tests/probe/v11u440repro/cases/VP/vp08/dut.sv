// § undefaultedPlaceholderRetry440
module m #(parameter fn) (input clk);
  integer f;
  initial f = $fopen(fn, "w");
endmodule
module top; m #(.fn("a.txt")) u(.clk(1'b0)); endmodule
