// § includeInactiveTabNotText141v
// case it01: `ifndef of a macro defined before the include; TAB-led define in the skipped branch
`define PRE
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
