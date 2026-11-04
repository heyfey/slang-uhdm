// § undefaultedPlaceholderRetry440
module m #(parameter w, parameter fn) (input clk, input [w-1:0] d);
  integer f;
  initial f = $fopen(fn, "r");
  initial $display("%s", fn);
endmodule
module top; m #(.w(4), .fn("x.txt")) u(.clk(1'b0), .d(4'h0)); endmodule
