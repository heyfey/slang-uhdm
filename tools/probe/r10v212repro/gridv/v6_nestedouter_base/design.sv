// v212 ADVERSARIAL v6 — the target generic lives in an ENCLOSING CLASS
// (r10sd1's b28 / verifier finding F1 shape).  `pb::outerb::innerb::tidb` is
// SUPPRESSED on both sides (probe 3 spells `pb::outerb::regb` and hits), while
// `work@ub::tidb` inherits `regb` through `extends pb::outerb` and can spell it
// unqualified, so our gate (3) does NOT fire there.  Two members, one generic:
// the group's base is the suppressed one and the patch clears the clone.
package pb;
  class baseb; endclass
  class outerb;
    class regb #(type T = baseb, string TN = "<unknown>"); endclass
    class innerb;
      typedef regb #(baseb, "in") tidb;
    endclass
  endclass
endpackage
class ub extends pb::outerb;
  typedef regb #(pb::baseb, "ub") tidb;
endclass
module topb;
  pb::outerb::innerb iv; ub vb;
  initial begin iv = null; vb = null; end
endmodule
