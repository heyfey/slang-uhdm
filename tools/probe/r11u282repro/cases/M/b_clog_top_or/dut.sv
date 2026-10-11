// § genCaSelBoundUnsizedClone282
package p; parameter int unsigned S = $clog2(16); endpackage
module top import p::*; (input logic [1:0] c, input logic [7:0] x, output logic [7:0] y6 [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    assign y6[g] = x[S:0] | 8'd0;
  end
endmodule
