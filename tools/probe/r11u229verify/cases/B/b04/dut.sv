// § sysCallTypeArgScopeJoin224 (a method-local typedef)
package p;
  class c;
    function int f(); typedef logic [4:0] m_t; return $bits(m_t); endfunction
  endclass
endpackage
module top(output int x);
  import p::*;
  c h;
  initial begin h = new; x = h.f(); end
endmodule
