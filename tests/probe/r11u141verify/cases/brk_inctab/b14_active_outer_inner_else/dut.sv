// § includeLeadTabIsText130v
// case b14_active_outer_inner_else: TAB before an inner else whose if-branch is inactive, outer active
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
