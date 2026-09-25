// § undefKeepsOtherRootMacro168
`undef FOO
`define FOO
`undef BAR
`define BAR
`include "inc.vh"
module top; m u(); endmodule
