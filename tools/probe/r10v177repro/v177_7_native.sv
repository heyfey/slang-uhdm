// r10v177 adversarial arm 7 — SHADOWING WITHOUT AN IMPORT.
//
// Arm 6 showed that a name ALSO reachable through an `import` resolves in
// golden (`enum_var`, and the typespec is the OUTER object).  This arm asks the
// SAME question with NO import anywhere: the outer same-named typedef is a
// NATIVE member of an enclosing scope.  `r10v140repro/v140_w_inherit.sv`'s
// `Kiln_pkg::Urn::urnShadowed` (a derived class re-typedefing its own
// package's name) is golden `ref_var` — i.e. a native enclosing declaration
// does NOT resolve — and this arm re-asks it at four more scope pairings under
// different names, so the shadow gate can be IMPORT-ONLY on measurement rather
// than on one cell.
typedef enum { UNI_P, UNI_Q } unibase7;
typedef unibase7 Twin7;                  // a $unit name, re-declared below

package Native7;
  typedef enum { NAT_A, NAT_B } natbase7;
  typedef natbase7 Twin7;                // shadows the $unit `Twin7` natively
  typedef natbase7 PkgOnly7;
  function Twin7   pkgTwin();   return NAT_A; endfunction
  function PkgOnly7 pkgUnique(); return NAT_B; endfunction

  class Inner7;
    typedef natbase7 Twin7;              // shadows Native7::Twin7 natively
    typedef natbase7 ClsOnly7;
    function Twin7    clsTwin();   return NAT_B; endfunction
    function ClsOnly7 clsUnique(); return NAT_A; endfunction
  endclass

  class Deep7 extends Inner7;
    typedef natbase7 Twin7;              // shadows BOTH natively
    function Twin7 deepTwin(); return NAT_A; endfunction
  endclass
endpackage

module native_top7;
  typedef enum { MOD_S, MOD_T } modbase7;
  typedef modbase7 Twin7;                // shadows the $unit `Twin7` natively
  typedef modbase7 ModOnly7;
  function Twin7    modTwin();   return MOD_S; endfunction
  function ModOnly7 modUnique(); return MOD_T; endfunction

  class InMod7;
    typedef modbase7 Twin7;              // shadows native_top7::Twin7 natively
    function Twin7 imTwin(); return MOD_T; endfunction
  endclass

  Native7::Inner7 i7 = new();
  Native7::Deep7  d7 = new();
  InMod7          m7 = new();
  initial $display(modTwin(), modUnique(), m7.imTwin(),
                   i7.clsTwin(), i7.clsUnique(), d7.deepTwin(),
                   Native7::pkgTwin(), Native7::pkgUnique());
endmodule
