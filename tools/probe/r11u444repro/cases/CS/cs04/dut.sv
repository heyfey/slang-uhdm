// § defaultedStrPlaceholderRetry444
module m #(parameter w, lg = "inv") (input clk, input [w:0] d, output reg o);
  initial $display("%s", lg);
  always @(posedge clk) o <= d[0];
endmodule
module top; endmodule
