// § undefaultedPlaceholderRetry440
module m #(parameter fn, parameter w = 4) (input clk);
  integer f;
  initial f = $fopen(fn, "w");
  logic [w-1:0] r;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
