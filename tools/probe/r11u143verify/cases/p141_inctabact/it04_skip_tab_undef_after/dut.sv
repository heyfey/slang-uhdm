// § includeInactiveTabNotText141v
// case it04: a TAB-led undef in a skipped branch, a plain undef after it
`define ON
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
