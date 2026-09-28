// § pkgFoldAtLeadingLeaf191 — v11u195 fresh: a package parameter read by a module generate condition and a for-generate bound
package p;
  parameter int W = 4;
  parameter int L = $clog2(W);
  parameter int S = W == 4 ? L : 1;
endpackage
module top(output logic [3:0] o);
  import p::*;
  for (genvar g = 0; g < S; g++) begin : gl
    assign o[g] = 1'b1;
  end
  if (S > 1) begin : gi
    assign o[3:2] = 2'b0;
  end
endmodule
