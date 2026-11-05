// module variables of the qualified type in two instances
package zp;
  typedef logic [7:0] zb_t;
endpackage
package ap;
  function int af (zp::zb_t a);
    return int'(a);
  endfunction
endpackage
module c;
  zp::zb_t w;
endmodule
module m;
  zp::zb_t z;
  c u1 ();
  c u2 ();
  int r;
  initial r = ap::af(z);
endmodule
