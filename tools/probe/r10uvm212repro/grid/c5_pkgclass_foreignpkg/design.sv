// CONTROL, r10sd1 cell b11's shape: package class, foreign package target.
// Golden FIRES here (SeqDriver/MiniAmiq) and must keep firing.
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
endpackage
package pb;
  import rp::*;
  class ub extends baseb;
    typedef regb #(ub, "ub") tidb;
  endclass
endpackage
module topb; import pb::*; ub vb; initial vb = null; endmodule
