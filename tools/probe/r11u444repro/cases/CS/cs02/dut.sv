// § defaultedStrPlaceholderRetry444
module m #(parameter lg = "inv") (input clk, output reg o);
  logic [31:0] c;
  always_comb begin
    o = 1'b0;
    if (c[23:lg] == 1'b1) o = 1'b1;
  end
endmodule
module top; endmodule
