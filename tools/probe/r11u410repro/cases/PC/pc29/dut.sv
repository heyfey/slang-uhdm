// § parenCastNameUnsupTs410
module m #(parameter W = 4) (input logic [7:0] i, output logic [7:0] o);
  assign o = (W)'(i);
endmodule
module top;
endmodule
