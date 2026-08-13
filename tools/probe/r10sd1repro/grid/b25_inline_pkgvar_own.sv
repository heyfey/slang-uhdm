package pb; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
  regb #(baseb, "baseb") pv1;
endpackage
module topb; import pb::*; initial pv1 = null; endmodule
