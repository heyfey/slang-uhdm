// two importer packages each return a bare call
package zp;
  typedef logic [7:0] zb_t;
  function zb_t zf (zb_t x);
    return x;
  endfunction
endpackage
package bp;
  import zp::*;
  function zb_t bf (zb_t a);
    return zf(a);
  endfunction
endpackage
package ap;
  import zp::*;
  function zb_t af (zb_t a);
    return zf(a);
  endfunction
endpackage
module m;
  logic [7:0] r;
  initial r = ap::af(8'h1) + bp::bf(8'h2);
endmodule
