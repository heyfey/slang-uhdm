// THE CORE CELL: a package ASSOCIATIVE array variable, wildcard-imported into a
// package that declares a class.  The class's listing gets a COPY, and the
// scored slot is that copy's array_typespec's INDEX typespec vpiInstance.
package p1;
  class k1;
    int x1;
  endclass
  k1 m1 [string];
endpackage

package q1;
  import p1::*;
  class c1;
    int own1;
  endclass
endpackage

module top1;
  q1::c1 h1;
endmodule
