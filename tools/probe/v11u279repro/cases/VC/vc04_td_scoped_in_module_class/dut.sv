// § clsTdScopedTargetQualSpan279
package rp; class regb #(int W = 1); endclass endpackage
module top;
  class ub;
    typedef rp::regb #(7) tidb;
    tidb h;
  endclass
  ub v; initial v = new();
endmodule
