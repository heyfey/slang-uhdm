// a typedef of a typedef, qualified formal
package zp;
  typedef logic [7:0] zb_t;
  typedef zb_t zc_t;
endpackage
package ap;
  function int af (zp::zc_t a);
    return int'(a);
  endfunction
endpackage
module m;
  int r;
  initial r = ap::af(8'h1);
endmodule
