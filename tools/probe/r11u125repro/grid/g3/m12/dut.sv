// § macroTokenFileFollowsLine125
`include "defs.svh"
module top(input clk, a, output reg q);
  always @(posedge clk) begin
    `SHOW2($sformatf("%0d", a));
    q <= a;
  end
endmodule
