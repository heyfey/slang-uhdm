// § includeNoTextSplicesNothing130
// case c01_define_block_comment: a trailing block comment on a define line
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
