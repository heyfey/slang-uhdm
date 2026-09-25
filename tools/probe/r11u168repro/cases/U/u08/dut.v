// § undefKeepsOtherRootMacro168
`define FOO 2
`undef FOO
`define FOO
`include "inc.vh"
module top; m u(); endmodule
