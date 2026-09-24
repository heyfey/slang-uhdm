// § macroTokenFileFollowsLine125
`include "defs.svh"
module top(input clk, a, output reg q);
  always @(posedge clk) begin
    `SHOW(a);
    q <= a;
  end
endmodule
