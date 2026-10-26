// § undefaultedPlaceholderRetry440
module m #(parameter n, parameter fn) (input clk);
  integer f;
  initial f = $fopen(fn, "w");
  for (genvar i = 0; i < n; i++) begin : g
    logic [7:0] r;
    always @(posedge clk) r <= i;
  end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
