// a6 — THE LAW'S ARM.  Three class-scope typedefs of ONE FOREIGN generic, each
// with a DIFFERENT concrete argument, so every member's own foreign-home gate
// fires.  SOURCE order is zeta6, alpha6, Mid6; Surelog's design-map key order
// is "pk6use::Mid6" < "pk6use::alpha6" < "pk6use::zeta6" (ASCII: M<a<z).
// If the base is the FIRST-SORTING declaring class, all three bind Q to Mid6.
// Source order, alphabetical-lowercase order and case are all separated here.
package pk6box;
  class BoxR #(type Q = int, string Nm = "?");
    int r1;
  endclass
endpackage
package pk6use;
  import pk6box::*;
  class zeta6;
    typedef BoxR #(zeta6,"zeta6") tid6;
  endclass
  class alpha6;
    typedef BoxR #(alpha6,"alpha6") tid6;
  endclass
  class Mid6;
    typedef BoxR #(Mid6,"Mid6") tid6;
  endclass
endpackage
