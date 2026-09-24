// § includeLeadTabIsText130v
// case b04_tab_def_inactive: TAB before a define in the INACTIVE branch
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
