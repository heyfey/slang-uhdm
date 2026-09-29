// § sysCallTypeArgScopeJoin224
package p;
  typedef logic [9:0] l_t;
  function automatic int f(); return $bits(l_t) + $size(l_t); endfunction
  task automatic t(output int o); o = $bits(l_t); endtask
endpackage
module top(output int o); assign o = p::f(); endmodule
