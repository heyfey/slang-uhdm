// THE DECISIVE CELL, and this pass's POSITIVE CONTROL.  Two class-scope
// typedefs of ONE foreign generic form a `clone_tree` group:
//   * `rp::rcb::tidb` -- the BASE (its owner key `rp::rcb` sorts before
//     `work@ub`).  Its target `regb` lives in rcb's OWN package, so
//     § classPkgGenericSpecListing53 suppresses its listing on both sides.
//   * `work@ub::tidb` -- a CLONE whose own `#(...)` text WOULD earn a listing
//     under § classTdSpecParamsForeignHome1 (foreign package home).
// This is Scoreboard's `uvm_pkg::*::type_id` / `work@my_scoreboard::type_id`
// shape with the UVM removed.  Golden gives the CLONE nothing, because
// `clone_tree` of a base with no listing has no listing.
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
module topb; import rp::*; ub vb; rcb rv; initial begin vb = null; rv = null; end endmodule
