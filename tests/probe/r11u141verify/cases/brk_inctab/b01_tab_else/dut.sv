// § includeLeadTabIsText130v
// case b01_tab_else: TAB before else (A undefined)
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
