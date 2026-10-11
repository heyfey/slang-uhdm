// § genProcOpFoldInPlace282
package pk; parameter int P = 4; endpackage
module top import pk::*;  (input logic [7:0] a [2], input logic [7:0] b, output logic [7:0] z [2]);
  for (genvar k1 = 0; k1 < 1; k1++) begin : g1
  for (genvar k2 = 0; k2 < 1; k2++) begin : g2
  for (genvar k3 = 0; k3 < 1; k3++) begin : g3
    always_comb z[0] = a[0][P-1] ? b + (P - 1) : {P{1'b0}};
  end
  end
  end
 endmodule
