// § sysCallTypeArgScopeJoin224 (a class-scope localparam initialised by $bits of a class typedef)
package p;
  class c;
    typedef logic [6:0] l_t;
    localparam int W = $bits(l_t);
    function int f(); return W + $bits(l_t); endfunction
  endclass
endpackage
module top(output int x);
  import p::*;
  c h;
  initial begin h = new; x = h.f(); end
endmodule
