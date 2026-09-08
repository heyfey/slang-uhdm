// c1 with TWO cu classes each carrying the typedef -- the GROUP/clone question:
// does the second one copy the first, and does either carry a listing?
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
endpackage
import rp::*;
class ub extends baseb;
  typedef regb #(ub, "ub") tidb;
endclass
class wb extends baseb;
  typedef regb #(wb, "wb") tidb;
endclass
module topb; ub vb; wb wv; initial begin vb = null; wv = null; end endmodule
