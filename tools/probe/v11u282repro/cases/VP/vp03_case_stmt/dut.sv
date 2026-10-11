// § genProcOpFoldInPlace282
package pk; parameter int P = 3; endpackage
module top import pk::*; (input logic [1:0] s, output logic [7:0] r [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb case (s) 2'd0: r[w] = P + 1; default: r[w] = P - 1; endcase
  end
endmodule
