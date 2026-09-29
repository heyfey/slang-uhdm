// § sysCallTypeArgScopeJoin224
program pr;
  typedef logic [9:0] l_t;
  function int f(); return $bits(l_t); endfunction
  initial $display(f());
endprogram
module top; endmodule
