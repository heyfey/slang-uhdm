// § sysCallTypeArgScopeJoin224
package p;
  typedef logic [63:0] t_t;
  function automatic int f();
    return $bits(t_t);
  endfunction
endpackage
module top(output int o); assign o = p::f(); endmodule
