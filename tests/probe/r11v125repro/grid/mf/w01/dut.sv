// § macroTokenFileFollowsLine125
`include "defs.svh"
module top(input logic [3:0] a, b, output logic [3:0] o);
  assign o = `ADD(a, b);
endmodule
