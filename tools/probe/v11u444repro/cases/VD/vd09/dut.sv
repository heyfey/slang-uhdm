// § defaultedStrPlaceholderRetry444
module m #(parameter w, lg = "inv") (input clk, output reg o);
  logic [23:0] c;
  always_ff @(posedge clk) o <= c[23:lg];
endmodule
module n #(parameter v, s = "inv") (input clk, output reg o);
  logic [23:0] c;
  always_ff @(posedge clk) o <= c[s:0];
endmodule
module top; endmodule
