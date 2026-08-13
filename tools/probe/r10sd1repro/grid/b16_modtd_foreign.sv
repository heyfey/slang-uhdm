package rp; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass endpackage
module topb; import rp::*;
  typedef regb #(baseb, "baseb") tidb;
  tidb vb; initial vb = null;
endmodule
