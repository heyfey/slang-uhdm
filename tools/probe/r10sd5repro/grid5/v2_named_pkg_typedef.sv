// v2 — the NAMED half.  The imported variable's type is a package-homed TYPEDEF,
// so the package's own copy legitimately carries the package on its typespec.
// 115 of our 165 SeqDriver surplus stamps are this shape, and the question the
// cell answers is whether golden ALSO drops the instance when the type is named.
package p2;
  typedef bit [3:0] t2;
  t2 v2 = 4'h5;
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
