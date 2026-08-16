// v1 — THE CORE CELL.  A package variable of an ANONYMOUS builtin type, wildcard-
// imported into a package that declares a class.  This is SeqDriver's shape at
// its smallest: the class listing must carry its OWN copy with no vpiInstance.
package p1;
  bit v1 = 1;
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
