// v83 arm 02 — PACKAGE FREE FUNCTION body local written Owner::td.
// pkgScope && !classScope  =>  tsInst = the package, pkgScopeInst = baseScopeInst.
// The patch stamps here.  Does golden?
package pa2;
  class zelem2; int q; endclass
  typedef zelem2 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  class zbase2;
    typedef zelem2 c_t;
  endclass
  function void freefn2();
    zbase2::c_t f_scoped;
    zelem2      f_plain;
  endfunction
endpackage
module top2;
  initial pa2::freefn2();
endmodule
