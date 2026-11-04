// § sysCallTypeArgScopeJoin224
typedef logic [9:0] l_t;
class c;
  function int f(); return $bits(l_t); endfunction
endclass
module top; endmodule
