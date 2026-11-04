// § sysCallTypeArgScopeJoin224 ($low, $right, $increment and $dimensions of a class typedef)
package p;
  class c;
    typedef logic [5:2] l_t;
    function int f(); return $low(l_t) + $right(l_t) + $increment(l_t) + $dimensions(l_t); endfunction
  endclass
endpackage
module top(output int x);
  import p::*;
  c h;
  initial begin h = new; x = h.f(); end
endmodule
