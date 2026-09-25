// § undefKeepsOtherRootMacro168
`define BAZ
`undef BAZ
`define BAZ
`include "inc.vh"
module top; m u(); endmodule
