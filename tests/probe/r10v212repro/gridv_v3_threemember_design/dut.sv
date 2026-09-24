// v212 ADVERSARIAL v3 — THREE MEMBERS, one suppressed base and TWO cu clones
// with DIFFERENT arguments.  The patch must clear BOTH clones, not just the
// first one the loop reaches.
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
  class rcb extends baseb;
    typedef regb #(rcb, "rcb") tidb;
  endclass
endpackage
import rp::*;
class ub extends baseb;
  typedef regb #(ub, "ub") tidb;
endclass
class wb extends baseb;
  typedef regb #(wb, "wb") tidb;
endclass
module topb; import rp::*; ub vb; wb wv; rcb rv; initial begin vb = null; wv = null; rv = null; end endmodule
