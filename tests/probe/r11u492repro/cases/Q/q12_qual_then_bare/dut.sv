// imported, qualified formal first then bare
package zp;
  typedef logic [7:0] zb_t;
endpackage
package ap;
  import zp::*;
  function int af (zp::zb_t a, zb_t b);
    return int'(a) + int'(b);
  endfunction
endpackage
module m;
  int r;
  initial r = ap::af(8'h1, 8'h2);
endmodule
