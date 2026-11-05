// imported, one formal bare and one qualified
package zp;
  typedef logic [7:0] zb_t;
endpackage
package ap;
  import zp::*;
  function int af (zb_t a, zp::zb_t b);
    return int'(a) + int'(b);
  endfunction
endpackage
module m;
  int r;
  initial r = ap::af(8'h1, 8'h2);
endmodule
