// § extendsScopedBaseNameSpan279
package rp; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass endpackage
`define BASE rp::baseb
package pb;
  class ub extends `BASE;
  endclass
endpackage
module top; pb::ub v; initial v = null; endmodule
