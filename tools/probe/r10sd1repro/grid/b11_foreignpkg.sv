// class-scope typedef whose TARGET generic class lives in ANOTHER package,
// reached by a wildcard import -- adpcm_pkg's relation to uvm_pkg.
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
endpackage
package pb;
  import rp::*;
  class ub extends baseb;
    typedef regb #(ub, "ub") tidb;
  endclass
endpackage
module topb; import pb::*; ub vb; initial vb = null; endmodule
