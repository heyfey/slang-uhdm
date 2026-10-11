// § genProcOpFoldInPlace282
package pk; parameter int NB = 3; parameter int ND = 2; endpackage
module top import pk::*; (output logic [15:0] r [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb r[w] = {8'(NB + ND), 8'(NB * ND)};
  end
endmodule
