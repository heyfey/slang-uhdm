// § objMacroParenArgsTrimmed160
`define NEG ~
module top (input logic x, input logic y, output logic o);
  assign o = `NEG (x & y);
endmodule
