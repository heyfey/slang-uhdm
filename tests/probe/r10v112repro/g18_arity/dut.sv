// g18 — ARITY MISMATCH.  The ASCII-first member passes ONE argument (the
// second takes the generic's default); the later members pass TWO.  The copy
// loop walks the BASE's Parameters, so a clone's extra argument must vanish.
package p18box;
  class B18 #(type Q = int, string Nm = "?"); int x18; endclass
endpackage
package p18use;
  import p18box::*;
  class Aa18; typedef B18 #(Aa18)          t18; endclass
  class mm18; typedef B18 #(mm18,"mm18")   t18; endclass
  class zz18; typedef B18 #(zz18,"zz18")   t18; endclass
endpackage
