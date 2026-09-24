// § includeNoTextSplicesNothing130
// case c02_undef_line_comment: a trailing line comment on an undef line
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
