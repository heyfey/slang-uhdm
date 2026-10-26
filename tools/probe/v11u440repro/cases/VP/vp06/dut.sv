// § undefaultedPlaceholderRetry440
module m #(parameter fn, parameter w) (input clk, input [w-1:0] d);
  integer f;
  initial f = $fopen(fn, "w");
  always @(posedge clk) $fwrite(f, "%d", d);
  localparam lw = w * 2;
  logic [lw-1:0] wide;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
