// § genProcOpFoldInPlace282
package pk; parameter int NB = 3; parameter int ND = 2; endpackage
module top import pk::*; (output logic [7:0] r [2][2]);
  for (genvar x = 0; x < 2; x++) begin : gx
    for (genvar y = 0; y < 2; y++) begin : gy
      always_comb r[x][y] = NB + ND;
    end
  end
endmodule
