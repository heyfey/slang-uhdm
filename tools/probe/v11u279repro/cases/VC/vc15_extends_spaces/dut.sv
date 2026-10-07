// § extendsScopedBaseNameSpan279
package rp; class baseb #(int W = 1); endclass endpackage
package pb;
  class ub extends rp :: baseb #( 3 );
  endclass
endpackage
module top; pb::ub v; initial v = new(); endmodule
