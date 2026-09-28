// § genForWholeLhsNestedKeep192v
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] z, output logic [31:0] z2 [1]);
  for (genvar i = 0; i < 1; i++) begin : g
    assign z2[i] = x[W:0] | 32'd0;
  end
endmodule
