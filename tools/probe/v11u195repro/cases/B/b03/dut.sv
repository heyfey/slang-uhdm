// § pkgFoldAtLeadingLeaf191 — v11u195 fresh: a nested product as the taken arm's first operand, a false-branch arm, a sum of two parameters
package p;
  parameter int W = 4;
  parameter int L = $clog2(W);
  parameter int S = W == 4 ? (L * 2) + 1 : 1;
  parameter int T = W != 4 ? 1 : W + L;
  parameter int U = W == 4 ? L << 1 : 0;
endpackage
module top(output int o);
  import p::*;
  assign o = S + T + U;
endmodule
