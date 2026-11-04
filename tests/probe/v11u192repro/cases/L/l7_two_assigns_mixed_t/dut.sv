// § genForWholeLhsNestedKeep192v
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] z [2], output wire [31:0] v);
  for (genvar i = 0; i < 2; i++) begin : g
    assign z[i] = x[W:0];
    assign v = x[31:W];
  end
endmodule
