// § undefaultedPlaceholderRetry440
module m #(parameter w, parameter fn) (input clk, output logic [w-1:0] q);
  integer f;
  initial f = $fopen(fn, "r");
  assign q = '0;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
