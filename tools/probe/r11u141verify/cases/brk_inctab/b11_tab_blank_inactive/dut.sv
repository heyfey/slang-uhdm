// § includeLeadTabIsText130v
// case b11_tab_blank_inactive: TAB-only line inside an inactive branch
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
