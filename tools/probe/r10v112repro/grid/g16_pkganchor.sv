// g16 — THE PACKAGE-ANCHORED CLONE PATH (§ classNestedClassTdJoinsPkgGroup50,
// the SECOND copyClassTdSpecParams1 call site, which r10uvm112 deliberately
// left refusing).  A PACKAGE-scope typedef of the generic anchors the group;
// a class-nested typedef of the same generic joins it as a clone with a
// DIFFERENT argument.
package p16box;
  class B16 #(type Q = int, string Nm = "?"); int x16; endclass
endpackage
package p16use;
  import p16box::*;
  class kk16; int k16; endclass
  class mm16; int m16; endclass
  typedef B16 #(kk16,"kk16") pkg_id16;
  class own16;
    typedef B16 #(mm16,"mm16") t16;
  endclass
endpackage
