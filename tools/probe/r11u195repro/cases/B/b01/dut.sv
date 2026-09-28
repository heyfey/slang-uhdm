// § pkgFoldAtLeadingLeaf191 — fresh: taken arms that are a parenthesized sum, a product with a parenthesized right operand, a nested ternary
package p;
  parameter int W = 4;
  parameter int L = $clog2(W);
  parameter int A = W == 4 ? (L + 1) : 2;
  parameter int B = W > 2 ? L * (W - 1) : 3;
  parameter int C = W < 2 ? 1 : W == 4 ? L - 1 : 5;
  localparam int D = W == 4 ? W : L;
endpackage
module top(output int o);
  import p::*;
  assign o = A + B + C + D;
endmodule
