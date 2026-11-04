// § genProcOpFoldUnaryKeepsInst282
package pk; parameter int M = 5; endpackage
module top import pk::*; (input logic c, input logic [7:0] a [2], output logic [7:0] z [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb z[w] = c ? ~M : a[w];
  end
endmodule
