// § includeLeadTabIsText130v
// case b03_tab_ifdef: TAB before ifdef
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
