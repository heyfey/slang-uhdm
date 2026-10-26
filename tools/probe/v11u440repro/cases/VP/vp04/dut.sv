// § undefaultedPlaceholderRetry440
module m #(parameter n, parameter string names [n-1:0]) (input clk);
  initial $display("%s", names[0]);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
