// r10uvm183 grid ARM C — THE DPI-ADJACENCY AXIS.
// r10uvm170's degrade window is `export "DPI-C"` written ABOVE a package
// subroutine (the body compiles one collect-pass early).  This arm asks
// whether THIS face's window is the same one: three functions that differ only
// in where the export sits (above / below / none), each with a `foreach`, in a
// home package and in its wildcard clone.  If the two windows were the same
// mechanism the `none` cell would resolve in the clone.
package wn183;
  export "DPI-C" function dpi_above;

  function automatic int dpi_above(input int seed_a);
    int rack_a[3];
    dpi_above = seed_a;
    foreach (rack_a[p1]) dpi_above += rack_a[p1];
  endfunction

  function automatic int dpi_below(input int seed_b);
    int rack_b[3];
    dpi_below = seed_b;
    foreach (rack_b[r2]) dpi_below += rack_b[r2];
  endfunction
  export "DPI-C" function dpi_below;

  function automatic int dpi_none(input int seed_c);
    int rack_c[3];
    dpi_none = seed_c;
    foreach (rack_c[s3]) dpi_none += rack_c[s3];
  endfunction

  // and the same three shapes over a FORMAL rather than a local
  export "DPI-C" function fml_above;
  function automatic int fml_above(input int one_a, input int two_a);
    int hold_a[2];
    hold_a[0] = one_a;
    hold_a[1] = two_a;
    fml_above = 0;
    foreach (hold_a[t4]) fml_above += hold_a[t4];
  endfunction
endpackage

package wnwild183;
  import wn183::*;
  function automatic int ring();
    return dpi_above(4) + dpi_below(5) + dpi_none(6) + fml_above(7, 8);
  endfunction
endpackage

module wn_top183;
  import wnwild183::*;
  int out183;
  initial out183 = ring();
endmodule
