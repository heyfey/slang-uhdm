// § includeLeadTabIsText130v
// case b08_tab_else_active: TAB before else, the first branch ACTIVE
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
