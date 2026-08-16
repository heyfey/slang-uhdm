// THE ELEM ARM: a package DYNAMIC array, same import shape.  The scored slot is
// the copy's array_typespec's ELEM typespec.
package p2;
  class k2;
    int x2;
  endclass
  k2 m2 [];
endpackage

package q2;
  import p2::*;
  class c2;
    int own2;
  endclass
endpackage

module top2;
  q2::c2 h2;
endmodule
