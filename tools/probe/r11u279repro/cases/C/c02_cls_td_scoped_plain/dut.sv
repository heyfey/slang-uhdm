// § clsTdScopedTargetQualSpan279
package rp; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass endpackage
package pb;
  class ub;
    typedef rp::baseb tb;
  endclass
endpackage
module top; pb::ub v; initial v = null; endmodule
