// § defaultedStrPlaceholderRetry444
module m #(parameter w, lg = 4) (input clk, input [w:0] d, output reg o);
  logic [23:0] c;
  always_comb o = c[23:lg] == 1'b1;
endmodule
module top; endmodule
