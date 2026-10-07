// § clsTdScopedTargetQualSpan279
package rp; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass endpackage
module top;
  class ub;
    typedef rp::regb #(ub, "ub") tidb;
  endclass
  ub v;
  initial v = null;
endmodule
