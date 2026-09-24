// § genvarIntTsRootFile130
module top(input logic [3:0] a, output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
`include "inner.svh"
  end
endmodule
