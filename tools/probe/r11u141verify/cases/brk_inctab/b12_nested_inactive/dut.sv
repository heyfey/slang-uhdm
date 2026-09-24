// § includeLeadTabIsText130v
// case b12_nested_inactive: TABs inside a nested block of an inactive branch
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
