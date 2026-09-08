// v212 ADVERSARIAL v5 — the base's argument NAMES A PARAMETER of the declaring
// class (r10sd1's b19/b5): Surelog's datatype_cast<const Parameter*> arm pushes
// NOTHING, our gate (4) drops the formal and emits no listing.  The clone's own
// text is concrete + foreign, so it earns one.  Does golden's clone carry the
// base's nothing?
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
endpackage
import rp::*;
class ab #(type P = baseb) extends baseb;
  typedef regb #(P, "ab") tidb;
endclass
class ub extends baseb;
  typedef regb #(ub, "ub") tidb;
endclass
module topb; import rp::*; ab #(baseb) av; ub vb; initial begin av = null; vb = null; end endmodule
