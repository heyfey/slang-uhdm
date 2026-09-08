// v212 ADVERSARIAL v8 — MUST-STAY.  Two PACKAGE classes in two DIFFERENT
// packages, both specializing a generic that is foreign to each: both earn a
// listing under § classTdSpecParamsForeignHome1 and the clone half copies the
// base's.  The patch must not touch either one.
package gp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
endpackage
package ap;
  import gp::*;
  class acb extends baseb;
    typedef regb #(acb, "acb") tidb;
  endclass
endpackage
package bp;
  import gp::*;
  class bcb extends baseb;
    typedef regb #(bcb, "bcb") tidb;
  endclass
endpackage
module topb; import gp::*; import ap::*; import bp::*; acb av; bcb bv; initial begin av = null; bv = null; end endmodule
