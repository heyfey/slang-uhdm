// § defaultedStrPlaceholderRetry444
module m #(parameter w, lg = "inv", hi = "inv") (input clk, output reg o);
  logic [31+w:0] c;
  always @(posedge clk)
    if (c[hi:lg] == 1'b1) o <= 1'b1;
endmodule
module top; endmodule
