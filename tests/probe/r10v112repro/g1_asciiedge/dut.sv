// g1 — BASE PICK, ASCII EDGE.  Class names chosen so that ASCII order,
// case-insensitive order and source order all DISAGREE:
//   ASCII:  "Zed1"(0x5A) < "_und1"(0x5F) < "aab1"(0x61)
//   ci:     aab1 < und1 < Zed1        source: aab1, _und1, Zed1
// If the base is the ASCII-first design-map key, all three bind Q to Zed1.
package p1box;
  class B1 #(type Q = int, string Nm = "?"); int x1; endclass
endpackage
package p1use;
  import p1box::*;
  class aab1;
    typedef B1 #(aab1,"aab1") t1;
  endclass
  class _und1;
    typedef B1 #(_und1,"_und1") t1;
  endclass
  class Zed1;
    typedef B1 #(Zed1,"Zed1") t1;
  endclass
endpackage
