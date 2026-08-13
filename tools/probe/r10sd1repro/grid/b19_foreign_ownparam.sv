package rp; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass endpackage
package pb; import rp::*;
  class gb #(type U = baseb);
    typedef regb #(U, "u") tidb;
  endclass
endpackage
module topb; import pb::*; gb #(rp::baseb) vb; initial vb = null; endmodule
