// class-scope typedef produced by a MACRO -- the span lands on the macro's own
// text, which is the one property SeqDriver's `uvm_object_utils` adds.
package pb;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
`define reg_utils(T) \
   typedef regb #(T, `"T`") tidb;
  class ub extends baseb;
    `reg_utils(ub)
  endclass
endpackage
module topb; import pb::*; ub vb; initial vb = null; endmodule
