// § undefKeepsOtherRootMacro168
`undef FOO
`define FOO // c
`include "inc.vh"
module top; m u(); endmodule
