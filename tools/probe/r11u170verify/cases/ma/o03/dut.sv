// § objMacroParenArgsTrimmed160
`define D
module sub (input logic i, output logic o); assign o = i; endmodule
module top (input logic x, output logic o);
  sub u(.i(`D ( ~x )), .o(o));
endmodule
