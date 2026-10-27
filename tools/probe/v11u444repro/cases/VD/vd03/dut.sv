// § defaultedStrPlaceholderRetry444
module m #(parameter w, lg = "inv", parameter string nm = "inv") (input clk, output reg o);
  logic [23:0] c;
  initial $display("%s", nm);
  always_comb begin
    o = 1'b0;
    if (c[23:lg] == 1'b1) o = 1'b1;
  end
endmodule
module top; endmodule
