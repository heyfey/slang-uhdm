// § undefKeepsOtherRootMacro168
`undef NEVERDEF
`define NEVERDEF
`undef OTHER
`define OTHER
`include "inc.vh"
module top; m u(); n v(); endmodule
