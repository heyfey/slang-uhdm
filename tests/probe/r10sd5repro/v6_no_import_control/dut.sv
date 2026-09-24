// v6 — THE NEGATIVE CONTROL.  Same package variable, same class, NO import.  The
// package's own listing must keep its stamp and the class must list nothing:
// this is the cell that fails if the fix nulls instances it was never handed.
package p6;
  typedef bit [3:0] t6;
  t6 v6 = 4'h9;
endpackage
package q6;
  class c6;
    p6::t6 own6;
  endclass
endpackage
module m6;
  q6::c6 h6;
endmodule
