// § undefKeepsOtherRootMacro168
`include "un.vh"
`define FOO
`define BAR
`include "inc.vh"
module top; m u(); endmodule
