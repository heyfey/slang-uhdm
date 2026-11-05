// vxpkg8 with every formal written bare: the import clone stamps the call actuals
package zp;
  typedef logic [7:0] zb_t;
  import "DPI-C" context function int dpi_z(input int a);
  function zb_t zf (zb_t x, zb_t y);
    return zb_t'(dpi_z(int'(x)) + y);
  endfunction
endpackage
package ap;
  import zp::*;
  function zb_t af (zb_t a, zb_t b);
    return zf(a, b);
  endfunction
endpackage
module m_xpkg;
  import zp::*;
  zb_t z;
  initial z = ap::af(8'h1, 8'h2);
endmodule
