// § pkgFoldAtLeadingLeaf191 — fresh: the folded package parameters used as part-select bounds through a wildcard import (composition with psBoundPaOwnerName192)
package p;
  parameter int W = 8;
  parameter int L = $clog2(W);
  parameter int H = W == 8 ? L + 4 : 1;
  parameter int K = W != 8 ? 1 : (L);
endpackage
module top(input logic [15:0] x, output logic [7:0] y, output logic [3:0] z);
  import p::*;
  assign y = x[H:0];
  assign z = x[K+3:K];
endmodule
