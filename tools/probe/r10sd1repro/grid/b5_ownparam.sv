package pb;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
  class gb #(type U = baseb);
    typedef regb #(U, "u") tidb;
  endclass
endpackage
module topb; import pb::*; gb #(baseb) vb; initial vb = null; endmodule
