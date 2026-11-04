// § macroTokenFileFollowsLine125
`define DEFCLK clk
`include "defs.svh"
module top(input clk, a, output reg q);
  `FLOP(q, a)
endmodule
