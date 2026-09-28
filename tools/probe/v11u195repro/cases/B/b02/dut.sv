// § pkgFoldAtLeadingLeaf191 — v11u195 fresh: taken arms that are a unary minus of a parameter and a parameter in a cast
package p;
  parameter int W = 4;
  parameter int L = $clog2(W);
  parameter int S = W == 4 ? -L : 1;
  parameter int T = W == 4 ? int'(L) : 2;
endpackage
module top(output int o);
  import p::*;
  assign o = S + T;
endmodule
