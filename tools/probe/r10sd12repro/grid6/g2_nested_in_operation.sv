// g2 — DEPTH CELL.  The reference is NOT the initialiser: it is an OPERAND of
// one.  If golden re-names/unbinds at depth too, the law is about every
// reference in the copied subtree; if it does not, the law is about the
// initialiser's ROOT only.  Either answer is a measurement, and this pass will
// not generalise past it without one.
package p2;
  int a2 = 1;
  int b2 = a2 + 1;
endpackage
package q2;
  import p2::*;
  class c2;
    int own2;
  endclass
endpackage
module m2;
  q2::c2 h2;
endmodule
