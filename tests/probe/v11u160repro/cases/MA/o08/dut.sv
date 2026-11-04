// § objMacroParenArgsTrimmed160
`define F $clog2
module top (output logic [3:0] a, output logic [3:0] b);
  assign a = `F  (  (16)  );  assign b = `F(8);
endmodule
