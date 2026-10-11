// § genProcOpFoldInPlace282
package pk; parameter int P = 3; endpackage
module top import pk::*; (output logic [7:0] r [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb begin
      r[w] = 0;
      for (int k = 0; k < P + 1; k++) r[w] = r[w] + 1;
    end
  end
endmodule
