// one importer package with a bare formal, another with a qualified formal
package zp;
  typedef logic [7:0] zb_t;
endpackage
package bp;
  import zp::*;
  function int bf (zb_t a);
    return int'(a);
  endfunction
endpackage
package ap;
  function int af (zp::zb_t a);
    return int'(a);
  endfunction
endpackage
module m;
  int r;
  initial r = bp::bf(8'h1) + ap::af(8'h2);
endmodule
