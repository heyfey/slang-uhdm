// § includeInactiveTabNotText141v
// case it07: an inner ifdef/else inside a skipped outer branch, TAB-led lines in both inner branches
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
