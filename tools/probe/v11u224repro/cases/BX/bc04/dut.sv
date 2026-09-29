// § sysCallTypeArgScopeJoin224
package p;
  typedef logic [9:0] l_t;
  class c;
    typedef struct packed { l_t a; logic b; } st_t;
    function int f(); return $bits(st_t) + $bits(p::l_t); endfunction
  endclass
endpackage
module top; endmodule
