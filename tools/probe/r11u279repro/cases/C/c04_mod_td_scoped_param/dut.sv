// § clsTdScopedTargetQualSpan279
package rp; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass endpackage
module top;
  typedef rp::regb #(int, "i") tidb;
  tidb v;
  initial v = null;
endmodule
