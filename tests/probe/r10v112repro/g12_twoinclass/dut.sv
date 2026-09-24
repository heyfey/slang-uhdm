// g12 — TWO typedefs of the same foreign generic INSIDE ONE class, plus one
// in another class.  Golden's group is keyed on the target generic, so all
// three are one group; the ASCII-first declaring class is Ab12, and the
// tie inside it is broken by the typedef NAME (t12a < t12b).
package p12box;
  class B12 #(type Q = int, string Nm = "?"); int x12; endclass
endpackage
package p12use;
  import p12box::*;
  class zz12; int z12; endclass
  class Ab12;
    typedef B12 #(zz12,"zz12") t12b;
    typedef B12 #(Ab12,"Ab12") t12a;
  endclass
  class cd12;
    typedef B12 #(cd12,"cd12") t12c;
  endclass
endpackage
