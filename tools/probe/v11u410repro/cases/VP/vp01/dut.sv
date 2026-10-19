// § parenCastNameUnsupTs410
module top #(parameter int W = 4) (input logic [7:0] x, output logic [7:0] y);
  assign y = (W)'(x);
endmodule
