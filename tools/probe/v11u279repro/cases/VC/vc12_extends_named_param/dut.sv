// § extendsScopedBaseNameSpan279
package rp; class baseb #(int W = 1, int D = 2); endclass endpackage
package pb;
  class ub extends rp::baseb #(.D(4));
  endclass
endpackage
module top; pb::ub v; initial v = new(); endmodule
