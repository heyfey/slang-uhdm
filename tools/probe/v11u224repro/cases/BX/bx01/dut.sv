// § sysCallTypeArgScopeJoin224
package q; typedef logic [15:0] h_t; endpackage
package p;
  import q::*;
  class c;
    function int f(); return $bits(h_t); endfunction
  endclass
endpackage
module top; endmodule
