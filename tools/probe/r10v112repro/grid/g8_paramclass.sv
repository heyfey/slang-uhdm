// g8 — a PARAMETERIZED class in the group beside a concrete one.  Its own
// argument names its OWN type parameter (cell b19 shape), the other two are
// concrete.  ASCII: Kp8 < mm8 < zz8, so the base is the parameterized one.
package p8box;
  class B8 #(type Q = int, string Nm = "?"); int x8; endclass
endpackage
package p8use;
  import p8box::*;
  class Kp8 #(type W8 = int);
    typedef B8 #(W8,"W8") t8;
  endclass
  class mm8;  typedef B8 #(mm8,"mm8") t8; endclass
  class zz8;  typedef B8 #(zz8,"zz8") t8; endclass
endpackage
module g8top;
  import p8use::*;
  Kp8 #(int)  i8a;
  Kp8 #(byte) i8b;
  mm8 i8c;
endmodule
