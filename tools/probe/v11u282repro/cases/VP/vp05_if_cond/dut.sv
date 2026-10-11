// § genProcOpFoldInPlace282
package pk; parameter int P = 4; endpackage
module top import pk::*; (input logic [7:0] a [2], output logic z [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb if (a[w] > P + 1) z[w] = 1'b1; else z[w] = 1'b0;
  end
endmodule
