package pb;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
  class ub extends baseb;
    typedef regb #(ub, "ub") tidb;
  endclass
  class wb extends baseb;
    typedef regb #(wb, "wb") tidb;
  endclass
endpackage
module topb; import pb::*; ub vb; wb wv; initial begin vb = null; wv = null; end endmodule
