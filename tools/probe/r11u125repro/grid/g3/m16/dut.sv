// § macroTokenFileFollowsLine125
`define ONEC 1'b1
`include "defs.svh"
module top(input a, output o, p);
  `NEST(o, p)
endmodule
