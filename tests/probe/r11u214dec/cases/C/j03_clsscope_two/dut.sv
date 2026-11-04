// § classScopeTdPkgListingParent214 — two class-scope typedefs of one generic with distinct arguments in two classes
package pbox;
  class Box #(type Q = int, string Nm = "?"); int b; endclass
endpackage
package puse;
  import pbox::*;
  class zeta;
    typedef Box #(zeta, "zeta") tid;
  endclass
  class alpha;
    typedef Box #(int, "alpha") uid;
  endclass
endpackage
