// § undefKeepsOtherRootMacro168
`undef FOO
`define FOO
`include "inc.vh"
module top; m u(); endmodule
