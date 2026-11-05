// an enum typedef, qualified formal
package zp;
  typedef enum logic [1:0] { ZA, ZB } ze_t;
endpackage
package ap;
  function int af (zp::ze_t e);
    return int'(e);
  endfunction
endpackage
module m;
  int r;
  initial r = ap::af(zp::ZB);
endmodule
