// § undefKeepsOtherRootMacro168
`undef FOO
`ifdef FOO
`define SEEN
`endif
`define FOO
`include "inc.vh"
module top; m u(); n v(); endmodule
