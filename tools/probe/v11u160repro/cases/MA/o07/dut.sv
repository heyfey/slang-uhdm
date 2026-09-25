// § objMacroParenArgsTrimmed160
`define W 4
module top (output logic [3:0] a, output logic [3:0] b);
  assign a = `W ( 1 ) ;
  assign b = 4'd1;
endmodule
