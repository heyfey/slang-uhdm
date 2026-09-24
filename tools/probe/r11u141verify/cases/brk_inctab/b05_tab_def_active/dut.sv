// § includeLeadTabIsText130v
// case b05_tab_def_active: TAB before a define in the ACTIVE branch
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
