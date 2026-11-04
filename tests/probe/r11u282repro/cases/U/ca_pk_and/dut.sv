// § genProcOpFoldUnaryKeepsInst282 (control: a continuous assignment, not a process)
package pk; parameter int unsigned P = 32'hF0; endpackage
module top import pk::*; (input logic [31:0] a [2], output logic [31:0] z [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    assign z[w] = a[w] & ~P;
  end
endmodule
