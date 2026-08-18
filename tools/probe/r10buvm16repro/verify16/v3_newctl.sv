// r10vbuvm16 arm v3 — THE `new` FAMILY CONTROLS in a package-only design.
// class new(args), super.new(args), shallow copy `new h`, a class new whose
// ARGUMENT is itself a dynamic-array size expr, a dynamic-array new nested in a
// class new's argument list, and the reverse.  None of the class forms may move.
package vpk3;

  int gpk3;

  function automatic int h3(int x); return x; endfunction

  class b3;
    int bp;
    int bda[];
    function new(int ba);
      int bl;
      bp = ba + bl;                 // v3_ctor_body
      bda = new[ba + bl];           // v3_ctor_newarray   <- law fires
    endfunction
  endclass

  class d3 extends b3;
    int dp;
    int dda[];
    function new(int da);
      int dl;
      super.new(da + dl);           // v3_supernew_args   <- MUST NOT move
      dda = new[da + dl];           // v3_ctor2_newarray
    endfunction

    extern function void m3(int mf);
    extern function void c3(int cf);
    extern function void n3(int nf);
  endclass

  // a class-new whose arguments are locals/formals: parented -> golden BINDS
  function void d3::m3(int mf);
    int ml;
    b3 hb;
    hb = new(mf + ml);              // v3_classnew_args   <- MUST NOT move
  endfunction

  // a shallow copy
  function void d3::c3(int cf);
    b3 hs, hc;
    int cl;
    hs = new(cf);
    hc = new hs;                    // v3_copyclass       <- MUST NOT move
  endfunction

  // a class new nested INSIDE a dynamic-array size, and a nested call
  function void d3::n3(int nf);
    int nl;
    dda = new[h3(nf) + h3(nl)];     // v3_newarr_twocalls <- law fires (both)
    dda = new[gpk3 + nl];           // v3_newarr_pkg_plus_local
  endfunction

  // package-level: class new + dynamic new side by side
  function automatic void f3(int ff);
    int fl;
    b3 hp;
    int fa[];
    hp = new(ff + fl);              // v3_pkgfn_classnew   <- MUST NOT move
    fa = new[ff + fl];              // v3_pkgfn_newarray   <- law fires
  endfunction

endpackage
