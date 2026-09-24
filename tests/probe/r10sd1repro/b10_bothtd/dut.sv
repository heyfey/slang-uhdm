package pb;
  class baseb; endclass
  class itemb extends baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
  class ub extends baseb;
    typedef regb #(ub, "ub") tidb;
  endclass
  typedef regb #(itemb, "itemb") ptidb;
endpackage
module topb; import pb::*; ub vb; ptidb pv; initial begin vb = null; pv = null; end endmodule
