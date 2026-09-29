// § sysCallTypeArgScopeJoin224 (a class nested in a class)
package p;
  class o;
    class n;
      typedef logic [5:0] l_t;
      function int f(); return $bits(l_t); endfunction
    endclass
  endclass
endpackage
module top(output int x);
  import p::*;
  o::n h;
  initial begin h = new; x = h.f(); end
endmodule
