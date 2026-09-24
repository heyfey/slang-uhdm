// forward reference in a package + formals of a PACKAGE TYPEDEF type, so the
// formal typespec carries an Instance() and the def/elab twin choice is
// cmp-VISIBLE (typespec::Compare recurses Instance()).
package gp;
  typedef logic [7:0] byte_t;
  import "DPI-C" context function int dpi_gl(input int a);
  function byte_t caller_early (byte_t a, byte_t b);
    return later_fn(a, b);
  endfunction
  function byte_t later_fn (byte_t x, byte_t y);
    return byte_t'(dpi_gl(int'(x)) + y);
  endfunction
endpackage
module m_fwdts;
  gp::byte_t z;
  initial z = gp::caller_early(8'h1, 8'h2);
endmodule
