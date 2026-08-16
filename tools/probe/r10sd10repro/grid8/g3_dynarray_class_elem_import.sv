// A DYNAMIC array of the same class type, same import shape.  sd7 scored this
// spelling on `array_typespec::Elem_typespec` and found `<null>` on both sides;
// this cell scores the ELEMENT VARIABLE instead, so the two spellings of "the
// element type" are separated by measurement rather than by assertion.
package p3;
  class k3;
    int x3;
  endclass
  k3 m3 [];
endpackage

package q3;
  import p3::*;
  class c3;
    int own3;
  endclass
endpackage

module top3;
  q3::c3 h3;
endmodule
