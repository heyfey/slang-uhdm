// § includeLeadTabIsText130v
// case b07_tab_elsif: TAB before elsif
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
