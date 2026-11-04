// § clsTdScopedTargetQualSpan279
package rp; class regb #(int W = 1, int D = 2); endclass endpackage
package pb;
  class ub;
    typedef rp::regb #(.D(3), .W(5)) tidb;
    tidb h;
  endclass
endpackage
module top; pb::ub v; initial v = null; endmodule
