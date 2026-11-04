// § includeInactiveTabNotText141v
// case it06: an ACTIVE multi-line define whose continuation line starts with a TAB
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
