// v212 ADVERSARIAL v7 — the MACRO FORM on the CLONE (c2 put it on a lone cell).
// The suppressed package base is written plainly; the cu clone's typedef comes
// out of a macro, the way `uvm_component_utils` writes `type_id`.  The macro
// form must not change the answer.
`define MKTID(C) typedef regb #(C, `"C`") tidb
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
  class rcb extends baseb;
    typedef regb #(rcb, "rcb") tidb;
  endclass
endpackage
import rp::*;
class ub extends baseb;
  `MKTID(ub);
endclass
module topb; import rp::*; ub vb; rcb rv; initial begin vb = null; rv = null; end endmodule
