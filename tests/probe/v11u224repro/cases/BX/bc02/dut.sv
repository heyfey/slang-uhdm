// § sysCallTypeArgScopeJoin224
package p;
  typedef logic [9:0] l_t;
  class c #(type T = int);
    function int f(); return $bits(T) + $bits(l_t); endfunction
  endclass
  class d extends c #(byte); endclass
endpackage
module top; endmodule
