// § extendsScopedBaseNameSpan279
package rp; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass endpackage
package pb;
  import rp::*;
  class ub extends baseb;
  endclass
endpackage
module top; pb::ub v; initial v = null; endmodule
