// the writer package does not import; another package imports the home package
package zp;
  typedef logic [7:0] zb_t;
  function zb_t zf (zb_t x);
    return x;
  endfunction
endpackage
package bp;
  import zp::*;
  function int bf (int i);
    return int'(zf(zb_t'(i)));
  endfunction
endpackage
package ap;
  function int af (zp::zb_t a);
    return int'(a);
  endfunction
endpackage
module m;
  int r;
  initial r = ap::af(8'h1) + bp::bf(2);
endmodule
