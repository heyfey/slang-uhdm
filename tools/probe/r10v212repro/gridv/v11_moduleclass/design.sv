// v212 ADVERSARIAL v11 — CLASS KIND: a class declared inside a MODULE, beside a
// package class whose typedef is suppressed.  A module-scope class is neither a
// compilation-unit class nor a package class, so neither Surelog's probe 2 nor
// probe 3 spells it; the group still has to obey the clone rule.
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
  class rcb extends baseb;
    typedef regb #(rcb, "rcb") tidb;
  endclass
endpackage
module topb;
  import rp::*;
  class mb extends baseb;
    typedef regb #(mb, "mb") tidb;
  endclass
  mb mv; rcb rv;
  initial begin mv = null; rv = null; end
endmodule
