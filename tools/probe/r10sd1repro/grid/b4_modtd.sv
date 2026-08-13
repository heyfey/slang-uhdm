package pb;
  class baseb; endclass
  class itemb extends baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
endpackage
module topb; import pb::*;
  typedef regb #(itemb, "itemb") tidb;
  tidb vb; initial vb = null;
endmodule
