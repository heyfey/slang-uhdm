// § genForWholeLhsNestedKeep192v
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] z [2], output logic [31:0] q [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    if (W > 1) begin : gi
      assign z[i] = {x[31:W], {W{1'b0}}};
      assign q[i] = x[W:0];
    end
  end
endmodule
