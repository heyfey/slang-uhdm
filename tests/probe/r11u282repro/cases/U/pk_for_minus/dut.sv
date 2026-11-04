// § genProcOpFoldUnaryKeepsInst282
package pk; parameter int unsigned P = 32'hF0; endpackage
module top import pk::*; (input logic [31:0] a [2], output logic [31:0] z [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb z[w] = -P + a[w];
  end
endmodule
module wrap(input logic [31:0] a [2], output logic [31:0] z [2]); top u (.a(a), .z(z)); endmodule
