// § extendsScopedBaseNameSpan279
package rp;
  class outer_c;
    class inner_c; endclass
  endclass
endpackage
package pb;
  class ub extends rp::outer_c::inner_c;
  endclass
endpackage
module top; pb::ub v; initial v = new(); endmodule
