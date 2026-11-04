// § sysCallTypeArgScopeJoin224
package p;
  typedef logic [63:0] t_t;
  class c;
    extern function bit f(int unsigned w);
  endclass
  function bit c::f(int unsigned w);
    if (w <= $bits(t_t)) return 1;
    return 0;
  endfunction
endpackage
module top; endmodule
