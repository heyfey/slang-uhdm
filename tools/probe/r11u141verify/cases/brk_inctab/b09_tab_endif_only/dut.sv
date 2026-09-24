// § includeLeadTabIsText130v
// case b09_tab_endif_only: TAB before endif after an active branch
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
