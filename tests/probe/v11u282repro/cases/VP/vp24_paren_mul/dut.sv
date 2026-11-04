// § genProcOpFoldInPlace282
package pk; parameter int NB = 3; parameter int ND = 2; endpackage
module top import pk::*; (output logic [7:0] r [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb r[w] = (NB + ND) * 2;
  end
endmodule
