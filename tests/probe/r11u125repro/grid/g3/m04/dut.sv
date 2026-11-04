// § macroTokenFileFollowsLine125
`include "defs.svh"
module top(input a, b, output o);
  `ASN(o, a ^ b)
endmodule
