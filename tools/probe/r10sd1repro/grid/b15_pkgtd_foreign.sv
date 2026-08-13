package rp; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass endpackage
package pb; import rp::*;
  class itemb extends baseb; endclass
  typedef regb #(itemb, "itemb") tidb;
endpackage
module topb; import pb::*; tidb vb; initial vb = null; endmodule
