// § sysCallTypeArgScopeJoin224
package p;
  typedef logic [9:0] l_t;
  class c;
    function int f(); return $bits(l_t); endfunction
  endclass
endpackage
package q;
  import p::*;
  class d extends c; endclass
endpackage
module top; endmodule
