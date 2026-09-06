// r10v177 adversarial arm 6 — THE TWO FACTORS THE BOUNDARY CELL CONFOUNDS.
//
// `r10v140repro/v140_r_import.sv`'s `work@bellows_top::Anvil::clsShadowed`
// (golden `enum_var`, pristine `enum_var`, PATCHED `ref_var` — a move AWAY)
// carries TWO features at once:
//     (i)  the class-scope typedef's own written base is a SCOPED name
//          (`Ember_pkg::heatBand`), and
//     (ii) the typedef's NAME is SHADOWED — an outer, already-bound typedef of
//          the SAME name (`Forge_pkg::HeatBand_e`) is visible at the class.
// Golden's typespec there is named `Forge_pkg::HeatBand_e`, i.e. Surelog
// resolved the return token to the OUTER typedef, not to the class's own — so
// (ii) is the suspect and (i) is a passenger.  This arm separates them: four
// classes, each carrying exactly one of the four (scoped-base × shadowed)
// combinations, in a MODULE and in a PACKAGE, plus the same two factors at
// MODULE and INTERFACE scope.
package Cinder2;
  typedef enum bit [2:0] { CIN_A = 1, CIN_B = 2, CIN_C = 4 } band2;
  typedef struct packed { bit [3:0] j; } word2;
endpackage

// An outer package whose aliases are wildcard-imported below, so a name
// declared again inside a class SHADOWS a bound outer typedef of that name.
package Outer2;
  import Cinder2::*;
  typedef Cinder2::band2 Shadowed_e;   // the name that gets shadowed
  typedef band2          Plain_e;
endpackage

module shadow_top2;
  import Outer2::*;
  import Cinder2::*;

  // MODULE-scope typedefs: scoped base vs bare base, neither shadowed.
  typedef Cinder2::band2 ModScopedBase;
  typedef band2          ModBareBase;
  function ModScopedBase modScoped(); return CIN_A; endfunction
  function ModBareBase   modBare();   return CIN_B; endfunction
  // a MODULE-scope typedef that SHADOWS the imported `Shadowed_e`
  typedef Cinder2::band2 Shadowed_e;
  function Shadowed_e modShadowed(); return CIN_C; endfunction

  class InModA;                              // NOT shadowed, SCOPED base
    typedef Cinder2::band2 UniqScoped;
    function UniqScoped mScoped(); return CIN_A; endfunction
  endclass
  class InModB;                              // NOT shadowed, BARE base (import)
    typedef band2 UniqBare;
    function UniqBare mBare(); return CIN_B; endfunction
  endclass
  class InModC;                              // SHADOWED, SCOPED base
    typedef Cinder2::band2 Plain_e;
    function Plain_e mShadScoped(); return CIN_C; endfunction
  endclass
  class InModD;                              // SHADOWED, BARE local base
    typedef enum { LOC_X, LOC_Y } locbase;
    typedef locbase Plain_e;
    function Plain_e mShadBare(); return LOC_X; endfunction
  endclass

  InModA ia = new(); InModB ib = new(); InModC ic = new(); InModD id = new();
  initial $display(modScoped(), modBare(), modShadowed(),
                   ia.mScoped(), ib.mBare(), ic.mShadScoped(), id.mShadBare());
endmodule

// The same four class shapes, but with the classes homed in a PACKAGE.
package Holder2;
  import Outer2::*;
  import Cinder2::*;
  class PkgA;
    typedef Cinder2::band2 UniqScoped;
    function UniqScoped pScoped(); return CIN_A; endfunction
  endclass
  class PkgB;
    typedef band2 UniqBare;
    function UniqBare pBare(); return CIN_B; endfunction
  endclass
  class PkgC;
    typedef Cinder2::band2 Plain_e;          // shadows Outer2::Plain_e
    function Plain_e pShadScoped(); return CIN_C; endfunction
  endclass
  class PkgD;
    typedef enum { PLOC_X, PLOC_Y } ploc;
    typedef ploc Plain_e;                    // shadows Outer2::Plain_e
    function Plain_e pShadBare(); return PLOC_X; endfunction
  endclass
  // package-scope controls: scoped base, bare base, and a shadowing name
  typedef Cinder2::band2 PkgScopedBase;
  typedef band2          PkgBareBase;
  typedef Cinder2::band2 Plain_e;            // shadows Outer2::Plain_e
  function PkgScopedBase pkgScoped(); return CIN_A; endfunction
  function PkgBareBase   pkgBare();   return CIN_B; endfunction
  function Plain_e       pkgShadowed(); return CIN_C; endfunction
endpackage

interface shadow_if2;
  import Outer2::*;
  import Cinder2::*;
  typedef Cinder2::band2 IfScopedBase;
  typedef band2          IfBareBase;
  typedef Cinder2::band2 Plain_e;            // shadows Outer2::Plain_e
  function IfScopedBase ifScoped(); return CIN_A; endfunction
  function IfBareBase   ifBare();   return CIN_B; endfunction
  function Plain_e      ifShadowed(); return CIN_C; endfunction
endinterface

module shadow_bench2;
  import Holder2::*;
  shadow_if2 sif();
  PkgA pa = new(); PkgB pb = new(); PkgC pc = new(); PkgD pd = new();
  initial $display(pa.pScoped(), pb.pBare(), pc.pShadScoped(), pd.pShadBare(),
                   pkgScoped(), pkgBare(), pkgShadowed(),
                   sif.ifScoped(), sif.ifBare(), sif.ifShadowed());
endmodule
