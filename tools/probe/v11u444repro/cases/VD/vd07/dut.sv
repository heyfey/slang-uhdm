// § defaultedStrPlaceholderRetry444
module ch(input clk); logic q; endmodule
module m #(parameter w, lg = "inv") (input clk, output reg o);
  logic [23:0] c;
  for (genvar i = 0; i < 2; i++) begin : gl
    ch u (.clk(clk));
  end
  always_comb begin
    o = 1'b0;
    if (c[23:lg] == 1'b1) o = 1'b1;
  end
endmodule
module top; logic clk; ch t0(.clk(clk)); endmodule
