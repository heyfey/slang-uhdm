// r10uvm123 arm B — a MODULE subroutine, and MODULE SCOPE, cast to a package
// vector typedef (both bit and logic spellings).
`define wid_B123 9
package Birch123Pkg;
  typedef bit   [`wid_B123-1:0] TWIG_BT;
  typedef logic [`wid_B123-1:0] twig_lt;
endpackage

module birch123_dut;
  import Birch123Pkg::*;
  TWIG_BT n_b;
  twig_lt n_l;
  // module-scope (no subroutine) cast sites
  assign n_b = TWIG_BT'(3);
  assign n_l = twig_lt'(4);
  function automatic int msub(int z);
    TWIG_BT lb;
    twig_lt ll;
    lb = TWIG_BT'(z);
    ll = twig_lt'(z);
    return 3;
  endfunction
endmodule
