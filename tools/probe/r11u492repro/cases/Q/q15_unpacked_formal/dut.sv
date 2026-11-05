// a qualified formal with an unpacked dimension
package zp;
  typedef logic [7:0] zb_t;
endpackage
package ap;
  function int af (zp::zb_t a [2]);
    return int'(a[0]);
  endfunction
endpackage
module m;
  int r;
  zp::zb_t v [2];
  initial r = ap::af(v);
endmodule
