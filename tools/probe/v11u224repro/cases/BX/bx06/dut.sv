// § sysCallTypeArgScopeJoin224
package p;
  typedef logic [9:0] l_t;
  class c;
    function int f();
      int r;
      begin : blk
        r = $bits(l_t);
      end
      return r;
    endfunction
  endclass
endpackage
module top; endmodule
