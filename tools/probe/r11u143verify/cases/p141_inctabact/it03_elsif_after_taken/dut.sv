// § includeInactiveTabNotText141v
// case it03: the first branch taken; TAB-led lines in the skipped elsif and else branches
`define ON
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
