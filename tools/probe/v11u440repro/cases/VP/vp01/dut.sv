// § undefaultedPlaceholderRetry440
module m #(parameter fn) (input clk);
  string s = fn;
  logic [7:0] r;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
