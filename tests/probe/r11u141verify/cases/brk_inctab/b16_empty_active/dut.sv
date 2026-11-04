// § includeLeadTabIsText130v
// case b16_empty_active: an EMPTY active branch, TAB before else
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
