// c1 + the typedef produced by a MACRO -- `uvm_component_utils`'s shape.
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
endpackage
import rp::*;
`define reg_utils(T) \
   typedef regb #(T, `"T`") tidb;
class ub extends baseb;
  `reg_utils(ub)
endclass
module topb; ub vb; initial vb = null; endmodule
