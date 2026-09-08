// v212 ADVERSARIAL v9 — MUST-STAY, mirror of v8's risk: a cu class with a
// FOREIGN target (listing) and a package class in the generic's OWN package
// (suppressed).  Whichever member our key picks as the base, no listing golden
// has may disappear.  Our key sorts "rp::rcb" first, so the base is the
// SUPPRESSED one and the cu clone is the one the patch clears.
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
  class rcb extends baseb;
    typedef regb #(baseb, "rcb") tidb;
  endclass
endpackage
package qp;
  import rp::*;
  class qcb extends baseb;
    typedef regb #(qcb, "qcb") tidb;
  endclass
endpackage
module topb; import rp::*; import qp::*; rcb rv; qcb qv; initial begin rv = null; qv = null; end endmodule
