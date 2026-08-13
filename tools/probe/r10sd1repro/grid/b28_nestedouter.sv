// VERIFIER CELL b28 -- the target generic is NESTED in the OUTER class that also
// encloses the referencing class.  Surelog probe 3 spells `pb::outerb::regb` and
// HITS, so golden carries NO specialization.  This is verifier FINDING F1: the
// delivered gate tested `home1->kind == SymbolKind::Package` only, missed this
// case and OVER-FIRED (golden PA=0, pristine PA=0, delivered-patch PA=1).
package pb;
  class baseb; endclass
  class outerb;
    class regb #(type T = baseb, string TN = "<unknown>"); endclass
    class ub extends baseb;
      typedef regb #(ub, "ub") tidb;
    endclass
  endclass
endpackage
module topb; import pb::*; outerb::ub vb; initial vb = null; endmodule
