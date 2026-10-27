// § defaultedStrPlaceholderRetry444
module m #(parameter w, lg = "") (input clk, output reg o);
  logic [23:0] c;
  always_comb begin
    o = 1'b0;
    if (c[lg:0] == 1'b1) o = 1'b1;
  end
endmodule
module top; endmodule
