// v212 ADVERSARIAL v4 — SCOPED-NAME BASE (r10sd1's b18 shape as the GROUP BASE).
// The base spells its target `rp::regb #(...)`, which Surelog's
// paPackage_scope arm mints as a BARE class_typespec.  Our gate (1) also
// refuses a ScopedName, so our base has a NULL listing — and the patch now
// propagates that absence onto the cu clone.  If golden's base DOES carry a
// listing here, this arm is a pristine-right -> patched-wrong regression.
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
endpackage
class qb extends rp::baseb;
  typedef rp::regb #(qb, "qb") tidb;
endclass
class ub extends rp::baseb;
  typedef rp::regb #(ub, "ub") tidb;
endclass
module topb; qb qv; ub vb; initial begin qv = null; vb = null; end endmodule
