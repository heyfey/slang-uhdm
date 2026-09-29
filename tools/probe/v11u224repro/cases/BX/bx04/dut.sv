// § sysCallTypeArgScopeJoin224
package p;
  typedef logic [9:0] l_t;
  class c #(int W = 1);
    function int f(); return $bits(l_t) * W; endfunction
  endclass
  class d extends c #(3); endclass
endpackage
module top(output int o);
  p::d h;
  initial begin h = new; o = h.f(); end
endmodule
