// § procPsBoundOwner192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x [2], output logic [31:0] y [2], output logic [31:0] z, output logic [31:0] q [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    always_comb y[i] = {1'b0, x[i][31:W]};
    always_comb q[i] = x[i][W:0];
  end
  if (W > 1) begin : gi
    always_comb z = x[0][W:0];
  end
endmodule
