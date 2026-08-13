package rp; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass endpackage
package pb; import rp::*;
  class ub extends baseb;
    typedef regb tidb;
  endclass
endpackage
module topb; import pb::*; ub vb; initial vb = null; endmodule
