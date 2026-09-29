// § sysCallTypeArgScopeJoin224
module top(output int o);
  typedef logic [63:0] t_t;
  function automatic int f();
    return $bits(t_t) + $size(t_t);
  endfunction
  assign o = f();
endmodule
