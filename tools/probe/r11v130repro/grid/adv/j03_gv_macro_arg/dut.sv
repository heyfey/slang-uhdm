// § genvarIntTsRootFile130
`define LOOP(v) for (genvar v = 0; v < 4; v++) begin : g assign o[v] = 1'b1; end
module top(output logic [3:0] o);
  `LOOP(kk)
endmodule
