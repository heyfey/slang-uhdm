// COMPILATION-UNIT class, target generic in ANOTHER package (wildcard import).
// This is `my_scoreboard`'s shape: r10sd1's b13 has the cu class with a cu
// target, b11 has a package class with a foreign target; this cell is the
// diagonal neither of them measured.
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
endpackage
import rp::*;
class ub extends baseb;
  typedef regb #(ub, "ub") tidb;
endclass
module topb; ub vb; initial vb = null; endmodule
