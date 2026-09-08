// c1 with an EXPLICIT single import instead of a wildcard.
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
endpackage
import rp::regb;
import rp::baseb;
class ub extends baseb;
  typedef regb #(ub, "ub") tidb;
endclass
module topb; ub vb; initial vb = null; endmodule
