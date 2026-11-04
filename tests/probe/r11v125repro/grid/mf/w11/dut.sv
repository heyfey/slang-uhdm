// § macroTokenFileFollowsLine125
`include "defs.svh"
module top(input logic a, output logic o);
  `F(n)
  assign o = f_n(a);
endmodule
