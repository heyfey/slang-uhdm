package pb;
  class baseb; endclass
  class itemb extends baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
endpackage
module topb; import pb::*; regb #(itemb, "itemb") vb; initial vb = null; endmodule
