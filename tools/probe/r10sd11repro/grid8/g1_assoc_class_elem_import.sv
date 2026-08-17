// THE CORE CELL.  A package ASSOCIATIVE ARRAY whose ELEMENT TYPE is a CLASS,
// wildcard-imported into a package that declares a class.  The importing
// class's listing gets a COPY of the array variable, and the scored slot is
// that copy's ELEMENT VARIABLE's typespec vpiInstance -- the object sd7's
// typespec-subtree walk could not reach, because an associative array's element
// type is not on `array_typespec::Elem_typespec` in these databases at all.
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
