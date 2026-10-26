// § undefaultedPlaceholderRetry440
module m #(parameter n, parameter fn) (input clk);
  integer f;
  initial f = $fopen(fn, "w");
  logic [7:0] mem [n];
  initial for (int i = 0; i < n; i++) mem[i] = '0;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
