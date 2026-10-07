// § extendsScopedBaseNameSpan279
package rp; class baseb; int x; endclass endpackage
module top;
  class ub extends rp::baseb;
    function void f(); x = 1; endfunction
  endclass
  ub v; initial v = new();
endmodule
