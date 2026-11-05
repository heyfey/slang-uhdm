// a qualified call of the home function from the importer
package zp;
  typedef logic [7:0] zb_t;
  function zb_t zf (zb_t x);
    return x;
  endfunction
endpackage
package ap;
  import zp::*;
  function zb_t af (zb_t a);
    return zp::zf(a);
  endfunction
endpackage
module m;
  logic [7:0] r;
  initial r = ap::af(8'h1);
endmodule
