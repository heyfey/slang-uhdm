// § macroTokenFileFollowsLine125
`include "defs.svh"
module top(input logic [3:0] a, output logic [3:0] o);
  `DECL(t)
  assign o = t;
endmodule
