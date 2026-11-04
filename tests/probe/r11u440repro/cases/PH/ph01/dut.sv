// § undefaultedPlaceholderRetry440
module m #(parameter w, parameter fn) (input clk, input [w-1:0] d);
  integer f = -1;
  always @(posedge clk) if (f == -1) f = $fopen(fn, "w");
  always @(negedge clk) $fwrite(f, "%x", d);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
