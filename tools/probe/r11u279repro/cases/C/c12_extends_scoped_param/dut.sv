// § extendsScopedBaseNameSpan279
package rp; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass endpackage
package pb;
  class ub extends rp::regb #(int, "x");
  endclass
endpackage
module top; pb::ub v; initial v = null; endmodule
