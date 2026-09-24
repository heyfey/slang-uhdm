// § includeInactiveTabNotText141v
// case it02: an inner skipped branch with a TAB line, then a TAB-led define in the ACTIVE outer branch
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
