// § defaultedStrPlaceholderRetry444
module m #(parameter w, lg = "inv", fn = "out.txt") (input clk, output reg o);
  integer f = -1;
  logic [23:0] c;
  always @(posedge clk) if (f == -1) f = $fopen(fn, "w");
  always_comb begin
    o = 1'b0;
    if (c[23:lg] == 1'b1) o = 1'b1;
  end
endmodule
module top; endmodule
