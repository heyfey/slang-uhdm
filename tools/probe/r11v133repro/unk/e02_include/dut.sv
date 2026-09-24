// § unknownParamOperandFile133
module top(output int o);
`include "defs.svh"
   localparam int C = XP / 2;
   assign o = int'(C);
endmodule
