package rp; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass endpackage
package pb;
  class ub extends rp::baseb;
    typedef rp::regb #(ub, "ub") tidb;
  endclass
endpackage
module topb; import pb::*; ub vb; initial vb = null; endmodule
