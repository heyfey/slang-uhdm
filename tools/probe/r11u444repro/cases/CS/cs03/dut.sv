// § defaultedStrPlaceholderRetry444
module m #(parameter w, parameter lg = "inv") (input clk, input [w-1:0] d, output o);
  logic [23:0] c;
  assign o = c[23:lg] == 1'b1;
endmodule
module top; endmodule
