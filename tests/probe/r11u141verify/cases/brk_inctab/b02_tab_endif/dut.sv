// § includeLeadTabIsText130v
// case b02_tab_endif: TAB before endif
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
