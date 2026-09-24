// § macroTokenFileFollowsLine125
`include "defs.svh"
`LEAF(leaf)
module top(input logic a, output logic o);
  leaf u(.a(a), .o(o));
endmodule
