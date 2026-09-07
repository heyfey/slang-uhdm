// r10v183 arm E — the INSTANCE half on the paths the DEGRADE half does NOT
// take: an EXPLICIT named-import copy (`import p::f;`), and the `::`-scoped
// spelling whose placeholder mint is NOT gated on `foreachUnres9` at all.
// Both now take `importCopyTsInst` where they took `pkgScopeInst`.
package sc183_home;
  class n183;
    static int statics[0:2];
  endclass

  int pkgarr[0:2];

  function automatic int f_scoped();
    int acc = 0;
    foreach (n183::statics[cc]) acc += n183::statics[cc];
    return acc;
  endfunction

  function automatic int f_bare(input int arg[0:2]);
    int acc = 0;
    foreach (arg[i]) acc += arg[i];
    return acc;
  endfunction

  function automatic int f_pkg();
    int acc = 0;
    foreach (pkgarr[i]) acc += pkgarr[i];
    return acc;
  endfunction
endpackage

// EXPLICIT named-import copies — no wildcard anywhere in this package
package sc183_expl;
  import sc183_home::f_scoped;
  import sc183_home::f_bare;
  import sc183_home::f_pkg;
  int use_expl;
  function automatic int kick_expl();
    int a[0:2];
    return f_scoped() + f_bare(a) + f_pkg();
  endfunction
endpackage

// WILDCARD clone of the same home, for the side-by-side
package sc183_wild;
  import sc183_home::*;
  export sc183_home::*;
  int use_wild;
  function automatic int kick_wild();
    int a[0:2];
    return f_scoped() + f_bare(a) + f_pkg();
  endfunction
endpackage

module sc183_top;
  import sc183_wild::*;
  int r;
  initial begin
    r = kick_wild() + sc183_expl::kick_expl();
  end
endmodule
