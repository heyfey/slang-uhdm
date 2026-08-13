// BOTH: foreign package target AND macro-produced typedef (SeqDriver exactly).
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
endpackage
package pb;
  import rp::*;
`define reg_utils(T) \
   typedef regb #(T, `"T`") tidb;
  class ub extends baseb;
    `reg_utils(ub)
  endclass
endpackage
module topb; import pb::*; ub vb; initial vb = null; endmodule
