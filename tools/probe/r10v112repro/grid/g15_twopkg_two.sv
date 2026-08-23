// g15 — exactly TWO members, in TWO PACKAGES, in ONE file, plus a third
// package holding the generic.  ASCII: "Pk15b::mem15" < "pk15a::mem15"
// ('P'=0x50 < 'p'=0x70), so the base is the SECOND package's member.
package p15box;
  class B15 #(type Q = int, string Nm = "?"); int x15; endclass
endpackage
package pk15a;
  import p15box::*;
  class mem15;
    typedef B15 #(mem15,"pk15a") t15;
  endclass
endpackage
package Pk15b;
  import p15box::*;
  class mem15;
    typedef B15 #(mem15,"Pk15b") t15;
  endclass
endpackage
