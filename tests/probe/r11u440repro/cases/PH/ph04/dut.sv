// § undefaultedPlaceholderRetry440
module m #(parameter w) (input clk, input [w-1:0] d);
  always @(posedge clk) $display("%d %s", d, undeclared_x);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
