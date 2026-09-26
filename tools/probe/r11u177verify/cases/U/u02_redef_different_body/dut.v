// § undefKeepsOtherRootMacro168
`undef FOO
`define FOO 2
`define BAZ
`include "inc.vh"
module top; m u(); n v(); endmodule
