// qualified RETURN type only, bare-int formal
package zp;
  typedef logic [7:0] zb_t;
endpackage
package ap;
  function zp::zb_t af (int a);
    return zp::zb_t'(a);
  endfunction
endpackage
module m;
  logic [7:0] r;
  initial r = ap::af(1);
endmodule
