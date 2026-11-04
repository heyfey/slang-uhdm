// § macroTokenFileFollowsLine125
`include "defs.svh"
module top(input logic [3:0] a, output logic [3:0] o);
  `CHK(a == 4'h0, "zero")
  assign o = a;
endmodule
