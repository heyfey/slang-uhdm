// § genProcOpFoldInPlace282
package pk; parameter int P = 4; endpackage
module top import pk::*; (output logic [7:0] r [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb begin r[w] = '0; r[w][P-1] = 1'b1; end
  end
endmodule
