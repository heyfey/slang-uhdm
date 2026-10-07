// § extendsScopedBaseNameSpan279
package rp; class baseb; endclass endpackage
package pb;
  class ub extends rp::baseb;
  endclass
  class ub2 extends rp::baseb;
  endclass
endpackage
module top; pb::ub v; pb::ub2 w; initial begin v = new(); w = new(); end endmodule
