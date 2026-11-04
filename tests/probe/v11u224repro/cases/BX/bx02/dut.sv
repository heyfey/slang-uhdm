// § sysCallTypeArgScopeJoin224
package p;
  class c;
    typedef logic [9:0] l_t;
    function int f(); return $bits(l_t) + $left(l_t) + $high(l_t); endfunction
  endclass
endpackage
module top; endmodule
