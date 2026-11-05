// a module function with a bare imported formal, a package function with a qualified one
package zp;
  typedef logic [7:0] zb_t;
endpackage
package ap;
  function int af (zp::zb_t a);
    return int'(a);
  endfunction
endpackage
module m;
  import zp::*;
  function int mf (zb_t a);
    return int'(a);
  endfunction
  int r;
  initial r = mf(8'h1) + ap::af(8'h2);
endmodule
