// § includeLeadTabIsText130v
// case b06_tab_ifndef: TAB before ifndef guard
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
