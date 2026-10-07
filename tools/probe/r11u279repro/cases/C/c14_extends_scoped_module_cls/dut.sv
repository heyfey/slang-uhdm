// § extendsScopedBaseNameSpan279
package rp; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass endpackage
module top;
  class ub extends rp::baseb;
  endclass
  ub v;
  initial v = null;
endmodule
