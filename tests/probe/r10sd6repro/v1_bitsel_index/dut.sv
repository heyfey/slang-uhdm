// v1 — VERIFIER cell.  The initialiser is a BIT-SELECT whose INDEX is a
// reference to another package variable.  The stated law says the walk
// "descends operations, SELECTS and call arguments"; this cell scores the
// select's INDEX reference, which is the only thing the select arm exists for.
package p1;
  logic [7:0] a1 = 8'h5;
  int idx1 = 1;
  logic b1 = a1[idx1];
endpackage
package q1;
  import p1::*;
  class c1;
    int own1;
  endclass
endpackage
module m1;
  q1::c1 h1;
endmodule
