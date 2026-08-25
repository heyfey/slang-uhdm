// r10uvm135 — GRID ARM a1: THE INDEX-KIND GRID.
// MEASUREMENT ONLY.  One HOME (an OUT-OF-BODY method of a package class) and
// one POSITION (a subroutine body local); what varies is HOW THE INDEX TYPE IS
// SPELLED.  Every cell carries its OWN name so no cell can be confirmed by
// another's answer, and the cells are deliberately NOT in "kind order".
package pkgScopedSigma135;
  class scopedTauCls135;
    int sv;
  endclass
  typedef enum { SIGMA_LO, SIGMA_HI } scopedUpsEnum135;
endpackage

package pkgKindAlpha135;
  typedef class fwdRhoCls135;

  class baseGammaCls135;
    int gv;
  endclass

  typedef baseGammaCls135 tdEtaHandle135;
  typedef enum { KAPPA_ONE, KAPPA_TWO, KAPPA_TRE } enumIotaKind135;
  typedef int tdLambdaInt135;
  typedef bit [7:0] tdNuVec135;

  class paramMuCls135 #(type PKEYNU135 = int);
    int pv;
  endclass

  class fwdRhoCls135;
    int fv;
  endclass

  class holderXiCls135;
    extern function void kindsOmicron135();
  endclass

  function void holderXiCls135::kindsOmicron135();
    bit c04Str135      [string];                              // 04 KEYWORD `string`
    bit c01ClsName135  [baseGammaCls135];                     // 01 a CLASS name
    bit c08TdInt135    [tdLambdaInt135];                      // 08 a TYPEDEF of `int`
    bit c03EnumTd135   [enumIotaKind135];                     // 03 an ENUM typedef
    bit c05Int135      [int];                                 // 05 KEYWORD `int`
    bit c02TdHandle135 [tdEtaHandle135];                      // 02 TYPEDEF of a class handle
    bit c10Scoped135   [pkgScopedSigma135::scopedTauCls135];  // 10 a SCOPED class name
    bit c07FwdTd135    [fwdRhoCls135];                        // 07 a FORWARD-typedef'd class
    bit c09Wild135     [*];                                   // 09 the `[*]` wildcard
    bit c11TdVec135    [tdNuVec135];                          // 11 a TYPEDEF of a vector
    bit c12ScopedEnu135[pkgScopedSigma135::scopedUpsEnum135];  // 12 a SCOPED enum typedef
    bit c06ParamCls135 [paramMuCls135#(int)];                 // 06 a PARAMETERIZED class
    c04Str135.delete();
    c01ClsName135.delete();
    c08TdInt135.delete();
    c03EnumTd135.delete();
    c05Int135.delete();
    c02TdHandle135.delete();
    c10Scoped135.delete();
    c07FwdTd135.delete();
    c09Wild135.delete();
    c11TdVec135.delete();
    c12ScopedEnu135.delete();
    c06ParamCls135.delete();
  endfunction
endpackage

module topKindBeta135;
  import pkgKindAlpha135::*;
  import pkgScopedSigma135::*;
  holderXiCls135 hOmegaKind135;
  initial begin
    hOmegaKind135 = new();
    hOmegaKind135.kindsOmicron135();
  end
endmodule
