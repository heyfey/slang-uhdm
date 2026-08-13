package pb;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
  class ub extends baseb;
    typedef regb #(ub, "ub") tidb;
  endclass
endpackage
module topb; import pb::*; ub vb; initial vb = null; endmodule
