// § undefaultedPlaceholderRetry440
module m #(parameter fn) (input clk);
  integer f;
  initial f = $fopen(fn, "w");
  logic [$bits(fn)-1:0] r;
  always @(posedge clk) r <= '0;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
