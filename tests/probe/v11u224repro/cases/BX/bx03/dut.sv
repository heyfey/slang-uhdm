// § sysCallTypeArgScopeJoin224
module top(output int o);
  typedef logic [9:0] l_t;
  class c;
    function int f(); return $bits(l_t); endfunction
  endclass
  c h;
  initial begin h = new; o = h.f(); end
endmodule
