// § pkgFoldAtLeadingLeaf191 — fresh: a macro-born ternary and a macro-born leaf in a package, read through a qualified name
`define PICK(c, a, b) ((c) ? (a) : (b))
`define LEAF 3
package p;
  parameter int W = 4;
  parameter int M = `PICK(W == 4, W + 1, 0);
  parameter int N = W == 4 ? `LEAF : 1;
endpackage
module top(output int o);
  assign o = p::M + p::N;
endmodule
