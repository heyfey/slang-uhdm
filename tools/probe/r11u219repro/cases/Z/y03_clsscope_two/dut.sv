// § classScopeTdPkgListingParent214 — class-scope specialization typedefs inside two classes of one package
package pbox;
  class Box #(type Q = int, int N = 1); int b; endclass
endpackage
package puse;
  import pbox::*;
  class one_c;
    typedef Box #(one_c, 3) b3_t;
  endclass
  class two_c;
    typedef Box #(two_c, 4) b4_t;
  endclass
endpackage
