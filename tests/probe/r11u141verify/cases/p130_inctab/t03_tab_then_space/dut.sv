// § includeLeadTabIsText130v
// case t03_tab_then_space: defs.svh with a TAB in a directive line's leading whitespace
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
