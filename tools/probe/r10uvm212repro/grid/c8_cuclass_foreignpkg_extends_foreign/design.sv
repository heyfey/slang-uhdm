// c1 where the cu class EXTENDS a foreign-package class and the typedef target
// is that same foreign package's generic -- `my_scoreboard extends
// uvm_scoreboard` with `uvm_component_registry`, exactly.
package rp;
  class baseb; endclass
  class midb extends baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
endpackage
import rp::*;
class ub extends midb;
  typedef regb #(ub, "ub") tidb;
endclass
module topb; ub vb; initial vb = null; endmodule
