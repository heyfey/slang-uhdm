// § macroTokenFileFollowsLine125
`include "defs.svh"
module top(input [`W-1:0] a, output [`W-1:0] o);
  assign o = a & `MASK;
endmodule
