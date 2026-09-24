// § includeNoTextSplicesNothing130
// case c04_comment_own_line: control: a comment on its own line (text per r11v125 z11)
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
