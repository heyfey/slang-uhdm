// g4 — REVERSE-RISK ARM.  The foreign generic is named with an EXPLICIT
// package qualifier (no wildcard import), so Surelog's typedef binding may
// resolve it EAGERLY and never take the clone_tree path.  If golden gives
// each typedef its OWN specialization, an overwrite would move cells AWAY.
package p4box;
  class B4 #(type Q = int, string Nm = "?"); int x4; endclass
endpackage
package p4use;
  class aa4;  typedef p4box::B4 #(aa4,"aa4") t4; endclass
  class bb4;  typedef p4box::B4 #(bb4,"bb4") t4; endclass
  class cc4;  typedef p4box::B4 #(cc4,"cc4") t4; endclass
endpackage
