// § undefaultedPlaceholderRetry440
module m #(parameter fn) (input clk);
  localparam L = fn;
  integer f;
  initial f = $fopen(L, "w");
  logic [7:0] r = L;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
