// g13 — the SAME class text `include`d into TWO packages: two distinct
// declarations with IDENTICAL source spans, plus a third distinct one.  The
// duplicate-declaration dedup (§ classNestedTdOneObjectPerSurelogTypedef97)
// and the base pick must both survive identical spans.
package p13box;
  class B13 #(type Q = int, string Nm = "?"); int x13; endclass
endpackage
package Ap13one;
  import p13box::*;
`include "inc13.svh"
endpackage
package zp13two;
  import p13box::*;
`include "inc13.svh"
endpackage
package p13three;
  import p13box::*;
  class Kk13;
    typedef B13 #(Kk13,"Kk13") t13;
  endclass
endpackage
