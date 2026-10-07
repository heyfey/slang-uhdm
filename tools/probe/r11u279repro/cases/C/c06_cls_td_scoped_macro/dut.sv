// § clsTdScopedTargetQualSpan279
package rp; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass endpackage
`define RT rp::regb
package pb;
  class ub;
    typedef `RT #(ub, "ub") tidb;
  endclass
endpackage
module top; pb::ub v; initial v = null; endmodule
