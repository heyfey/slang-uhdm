// v136 arm K — the § classScopedTypedefPropIsBareLogicVar73 BOUNDARY: exotic
// qualified spellings of a packed-struct face.  If golden degrades any of these
// to a bare logic_var and we now hand back a struct_var, that is an AWAY.
package Pk_Q;
  class Home;
    typedef struct packed { bit [3:0] hA; bit [3:0] hB; } homeSpan_S;
    typedef union  packed { bit [7:0] hU; bit [7:0] hV; } homeWrap_U;
    homeSpan_S k01_ownProp;
  endclass
  typedef Home::homeSpan_S aliasOfClassTd_S;      // package alias of a CLASS typedef
  typedef struct packed { bit [5:0] pA; bit [1:0] pB; } pkgSpan_S;
  typedef pkgSpan_S pkgAlias_S;

  class Users;
    Home::homeSpan_S k02_clsQual;                 // class-qualified   (§73 population)
    Home::homeWrap_U k03_clsQualU;
    aliasOfClassTd_S k04_aliasOfClsTd;            // the alias hides the class scope
    Pk_Q::pkgSpan_S  k05_pkgQual;                 // package-qualified, same package
    pkgAlias_S       k06_pkgAlias;
  endclass
endpackage

package Pk_Q2;
  import Pk_Q::*;
  class Outsiders;
    Pk_Q::Home::homeSpan_S k07_pkgClsQual;        // package+class qualified
    Pk_Q::pkgSpan_S        k08_xpkgQual;
    Pk_Q::aliasOfClassTd_S k09_xpkgAliasOfClsTd;
  endclass
endpackage

interface if_q_v136;
  typedef struct packed { bit [2:0] iA; bit [4:0] iB; } ifqSpan_S;
  logic sig;
endinterface

module mod_q_top;
  import Pk_Q::*;
  typedef struct packed { bit [1:0] mA; bit [6:0] mB; } modSpan_S;
  class ModUser;
    modSpan_S        k10_modTd;
    Home::homeSpan_S k11_clsQualFromMod;
    aliasOfClassTd_S k12_aliasFromMod;
  endclass
  ModUser u1, u2;
endmodule
