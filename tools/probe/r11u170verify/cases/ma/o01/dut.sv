// § objMacroParenArgsTrimmed160
`define D
module top (input logic x, input logic y, output logic [1:0] o);
  assign o = `D ( {x, y} );
endmodule
