// § includeLeadTabIsText130v
// case b15_empty_inactive: an EMPTY inactive branch, TAB before else
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
