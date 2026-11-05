// the writer package imports the home package, whose function has bare formals
package zp;
  typedef logic [7:0] zb_t;
  function zb_t zf (zb_t x, zb_t y);
    return x + y;
  endfunction
endpackage
package ap;
  import zp::*;
  function int af (zp::zb_t a, zp::zb_t b);
    return int'(zf(a, b));
  endfunction
endpackage
module m;
  int r;
  initial r = ap::af(8'h1, 8'h2);
endmodule
