// § defaultedStrPlaceholderRetry444
module m #(parameter w, parameter string lg = "inv") (input clk, output reg o);
  logic [23+w:0] c;
  initial $display("%s", lg);
  always_comb begin
    o = 1'b0;
    if (c[23:w] == 1'b1) o = 1'b1;
  end
endmodule
module top; endmodule
