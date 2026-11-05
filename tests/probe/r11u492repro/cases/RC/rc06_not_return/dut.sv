// the bare call is an assignment, not a return
package zp;
  typedef logic [7:0] zb_t;
  function zb_t zf (zb_t x);
    return x;
  endfunction
endpackage
package ap;
  import zp::*;
  function zb_t af (zb_t a);
    zb_t t;
    t = zf(a);
    return t;
  endfunction
endpackage
module m;
  logic [7:0] r;
  initial r = ap::af(8'h1);
endmodule
