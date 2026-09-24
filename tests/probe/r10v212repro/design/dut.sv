// v212 ADVERSARIAL v10 — a THREE-DEEP inheritance chain whose class-scope
// typedefs all target one foreign generic, plus a suppressed package member, so
// the group has four members and the base is the suppressed one.  Exercises the
// loop's skip rules (base copy, already-aliased member) with the new clear.
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
  class rcb extends baseb;
    typedef regb #(rcb, "rcb") tidb;
  endclass
endpackage
import rp::*;
class ub extends baseb;
  typedef regb #(ub, "ub") tidb;
endclass
class ub2 extends ub;
  typedef regb #(ub2, "ub2") tidb;
endclass
class ub3 extends ub2;
  typedef regb #(ub3, "ub3") tidb;
endclass
module topb; import rp::*; ub3 v3; rcb rv; initial begin v3 = null; rv = null; end endmodule
