// § undefaultedPlaceholderRetry440
module m #(parameter fn, parameter n) (input clk);
  integer f;
  initial f = $fopen(fn, "w");
  for (genvar i = 0; i < n; i++) begin : g
    logic r;
  end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
