// v212 ADVERSARIAL v12 — CLASS KIND: a VIRTUAL class carries the group's base
// typedef (uvm_object / uvm_component are virtual), with a concrete cu clone.
package rp;
  virtual class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
  virtual class rcb extends baseb;
    typedef regb #(rcb, "rcb") tidb;
  endclass
endpackage
import rp::*;
class ub extends rcb;
  typedef regb #(ub, "ub") tidb;
endclass
module topb; import rp::*; ub vb; initial vb = null; endmodule
