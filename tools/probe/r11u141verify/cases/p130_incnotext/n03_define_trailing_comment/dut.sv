// § includeNoTextSplicesNothing130
// case n03_define_trailing_comment: the included file defs.svh, then a second include and code
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
