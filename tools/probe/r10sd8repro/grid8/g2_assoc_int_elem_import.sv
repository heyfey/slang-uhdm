// THE SAME ARM, A DIFFERENT ELEMENT TYPESPEC CLASS: the element type is the
// built-in `int`, so the law cannot have been read off `class_typespec`.
package p2;
  int m2 [string];
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
