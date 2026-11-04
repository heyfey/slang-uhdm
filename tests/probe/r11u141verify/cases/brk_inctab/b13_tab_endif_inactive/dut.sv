// § includeLeadTabIsText130v
// case b13_tab_endif_inactive: TAB before endif closing an inactive branch
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
