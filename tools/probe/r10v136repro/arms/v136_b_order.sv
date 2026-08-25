// v136 arm B — WHERE the typedef lives relative to the class.
`include "v136_b_order_inc.svh"
package Pk_Later;
  typedef struct packed { bit [2:0] hopA; bit [4:0] hopB; } laterSpan_S;
endpackage

package Pk_Order;
  import Pk_Early::*;

  class UsesEarly;
    earlySpan_S     b01_incFirst;      // typedef from an INCLUDEd file
    Pk_Early::earlySpan_S b02_qualEarly;
  endclass

  typedef struct packed { bit [6:0] sameA; bit [0:0] sameB; } sameFileAfter_S;

  class UsesAfterDecl;                 // class textually BEFORE its typedef use? no: after
    sameFileAfter_S b03_sameFile;
    Pk_Later::laterSpan_S b04_xpkgQual;
  endclass
endpackage

package Pk_Wild;
  import Pk_Later::*;
  class WildUser;
    laterSpan_S b05_xpkgWild;
  endclass
endpackage

package Pk_InClass;
  class InClassTd;
    typedef struct packed { bit [3:0] innA; bit [3:0] innB; } localSpan_S;
    localSpan_S b06_inClass;
    typedef union packed { bit [7:0] u1; bit [7:0] u2; } localU_S;
    localU_S    b07_inClassU;
  endclass
  class QualUser;
    InClassTd::localSpan_S b08_clsQual;   // CLASS-QUALIFIED — must stay logic_var (§73)
  endclass
endpackage
