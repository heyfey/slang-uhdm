// § genProcOpFoldInPlace282
package pk; parameter int NB = 3; parameter int ND = 2; endpackage
module c import pk::*; (output logic [7:0] r [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb r[w] = NB + ND;
  end
endmodule
module top(output logic [7:0] r1 [2], output logic [7:0] r2 [2]); c u1(.r(r1)); c u2(.r(r2)); endmodule
