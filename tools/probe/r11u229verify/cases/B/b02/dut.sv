// § sysCallTypeArgScopeJoin224 (a typedef inherited from the base class)
package p;
  class c;
    typedef logic [5:0] t_t;
  endclass
  class d extends c;
    function int f(); return $bits(t_t); endfunction
  endclass
endpackage
module top(output int x);
  import p::*;
  d h;
  initial begin h = new; x = h.f(); end
endmodule
