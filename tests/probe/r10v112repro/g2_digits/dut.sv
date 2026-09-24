// g2 — BASE PICK, DIGITS AND LENGTH.  "c2" vs "c10" vs "c2a": ASCII gives
// c10 < c2 < c2a (digit '1'(0x31) < '2'(0x32)), numeric order gives c2 < c2a
// < c10.  Source order is c2, c2a, c10.  ASCII-first key => base c10.
package p2box;
  class B2 #(type Q = int, string Nm = "?"); int x2; endclass
endpackage
package p2use;
  import p2box::*;
  class c2;   typedef B2 #(c2,"c2")   t2; endclass
  class c2a;  typedef B2 #(c2a,"c2a") t2; endclass
  class c10;  typedef B2 #(c10,"c10") t2; endclass
endpackage
