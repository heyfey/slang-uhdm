// TWO packages: the IMPORTER is declared first in the file, the DEFINER second.
// Legal: a package may reference a package compiled later only if the compiler
// orders by dependency, so both orders are exercised here (ap uses zp, and zp
// is written AFTER ap in the file is illegal for Surelog -> keep zp first, and
// use the NAME ordering ap<zp to probe emission order instead).
package zp;
  typedef logic [7:0] zb_t;
  import "DPI-C" context function int dpi_z(input int a);
  function zb_t zf (zb_t x, zb_t y);
    return zb_t'(dpi_z(int'(x)) + y);
  endfunction
endpackage
package ap;
  import zp::*;
  function zp::zb_t af (zp::zb_t a, zp::zb_t b);
    return zf(a, b);
  endfunction
endpackage
module m_xpkg;
  zp::zb_t z;
  initial z = ap::af(8'h1, 8'h2);
endmodule
