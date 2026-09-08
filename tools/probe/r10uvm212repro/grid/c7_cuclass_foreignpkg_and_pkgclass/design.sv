// BOTH a cu class and a package class carry the typedef of the SAME foreign
// generic.  If golden is all-or-nothing per generic (the clone/base mechanism)
// this cell says WHICH one wins the base.
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
endpackage
package pb;
  import rp::*;
  class pcb extends baseb;
    typedef regb #(pcb, "pcb") tidb;
  endclass
endpackage
import rp::*;
class ub extends baseb;
  typedef regb #(ub, "ub") tidb;
endclass
module topb; import pb::*; ub vb; pcb pv; initial begin vb = null; pv = null; end endmodule
