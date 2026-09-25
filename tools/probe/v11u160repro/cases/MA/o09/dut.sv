// § objMacroParenArgsTrimmed160
`define F $clog2
`define G(x) `F (x)
module top (output logic [3:0] a, output logic [3:0] b);
  assign a = `G(16); assign b = 4'd1;
endmodule
