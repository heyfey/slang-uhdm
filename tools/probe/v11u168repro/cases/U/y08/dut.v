// § undefKeepsOtherRootMacro168
`include "inc0.vh"
`undef FOO
`define FOO
`include "inc.vh"
`undef BAR
`define BAR
`include "inc2.vh"
module top; m u(); m0 u0(); m2 u2(); endmodule
