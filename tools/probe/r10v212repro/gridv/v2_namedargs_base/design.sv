// v212 ADVERSARIAL v2 — NAMED-ARG BASE.  The base's own `#(...)` is written with
// NAMED arguments, which Surelog's ordered-only loop leaves as EMPTY vectors and
// our emitter leaves as a NULL one.  The clone's text is ordered + foreign-home,
// so it earns a listing of its own.  Post-patch the clone is cleared to NULL,
// which BaseClass.h:217-222 treats as equal to golden's empty vector.
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
  class rcb extends baseb;
    typedef regb #(.T(rcb), .TN("rcb")) tidb;
  endclass
endpackage
import rp::*;
class ub extends baseb;
  typedef regb #(ub, "ub") tidb;
endclass
module topb; import rp::*; ub vb; rcb rv; initial begin vb = null; rv = null; end endmodule
