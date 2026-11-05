// a qualified formal inside the typedef's own package (abstains)
package zp;
  typedef logic [7:0] zb_t;
  function int zf (zp::zb_t a);
    return int'(a);
  endfunction
endpackage
module m;
  int r;
  initial r = zp::zf(8'h1);
endmodule
