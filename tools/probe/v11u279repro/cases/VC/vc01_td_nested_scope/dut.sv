// § clsTdScopedTargetQualSpan279
package rp;
  class outer_c;
    class inner_c #(int W = 1); endclass
  endclass
endpackage
package pb;
  class ub;
    typedef rp::outer_c::inner_c #(4) tidb;
  endclass
endpackage
module top; pb::ub v; initial v = null; endmodule
