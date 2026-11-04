// § genProcOpFoldUnaryKeepsInst282
package pk; parameter int P = 1; endpackage
module top import pk::*; (input logic [7:0] a [2], output logic z [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb z[w] = a[w][-P + 2];
  end
endmodule
