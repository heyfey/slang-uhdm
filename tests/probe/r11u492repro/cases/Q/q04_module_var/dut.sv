// a module variable of the qualified type besides the qualified formal
package zp;
  typedef logic [7:0] zb_t;
endpackage
package ap;
  function int af (zp::zb_t a);
    return int'(a);
  endfunction
endpackage
module m;
  zp::zb_t z;
  int r;
  initial r = ap::af(z);
endmodule
