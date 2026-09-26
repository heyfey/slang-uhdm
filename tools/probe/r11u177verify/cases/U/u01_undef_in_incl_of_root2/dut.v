// § undefKeepsOtherRootMacro168
`include "undef.vh"
`define FOO
`define BAR
`include "inc.vh"
module top; m u(); n v(); endmodule
