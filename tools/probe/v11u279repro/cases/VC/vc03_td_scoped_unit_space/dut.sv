// § clsTdScopedTargetQualSpan279
package rp; class regb #(int W = 1); endclass endpackage
package pb;
  class ub;
    typedef rp :: regb #(2) tidb;
  endclass
endpackage
module top; pb::ub v; initial v = null; endmodule
