// § defaultedStrPlaceholderRetry444
module m #(parameter w, parameter fn, parameter lg = "inv") (input clk, input [w-1:0] d, output reg o);
  integer f = -1;
  logic [23:0] c;
  always @(posedge clk) if (f == -1) f = $fopen(fn, "w");
  always_comb begin
    o = 1'b0;
    if (c[23:lg] == 1'b1) o = 1'b1;
  end
endmodule
module top; endmodule
