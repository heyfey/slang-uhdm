// CONTROL for c9: the SUPPRESSED base alone, with no clone.  Golden gives it no
// listing and neither binary may give it one.
package rp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
  class rcb extends baseb;
    typedef regb #(rcb, "rcb") tidb;
  endclass
endpackage
module topb; import rp::*; rcb rv; initial rv = null; endmodule
