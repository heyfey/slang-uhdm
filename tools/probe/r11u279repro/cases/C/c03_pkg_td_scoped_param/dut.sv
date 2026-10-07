// § clsTdScopedTargetQualSpan279
package rp; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass endpackage
package pb;
  typedef rp::regb #(int, "i") tidb;
endpackage
module top; pb::tidb v; initial v = null; endmodule
