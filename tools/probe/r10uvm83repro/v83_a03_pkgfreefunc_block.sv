// v83 arm 03 — PACKAGE FREE FUNCTION, BLOCK-ITEM local (SITE 2, pkgScopeInst).
package pa3;
  class zelem3; int q; endclass
  typedef zelem3 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  class zbase3;
    typedef zelem3 c_t;
  endclass
  function void freefn3();
    begin : blk3
      zbase3::c_t b_scoped;
      zelem3      b_plain;
    end
  endfunction
endpackage
module top3;
  initial pa3::freefn3();
endmodule
