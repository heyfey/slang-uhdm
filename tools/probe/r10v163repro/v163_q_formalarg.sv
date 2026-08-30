// r10v163 — arm Q: the SHAPE of the regression found in arm P.  Golden's
// ordered-argument loop pushes NOTHING for a written argument that names a
// TYPE FORMAL of the enclosing generic class (p03/p11), while still ADVANCING
// the index (p06 pairs the concrete `CfgBet` with the SECOND formal `TWO`).
// This arm asks how far "a type formal" reaches: an OUTER class's formal seen
// from a nested class, a MODULE's type parameter seen from a class inside it,
// an INTERFACE's, and — the negative control the fix must not swallow — a
// class-scope TYPEDEF, which is resolvable and must keep its entry.
//
// LHS is ALWAYS golden(Surelog); RHS is always ours.

package Pk_Gimel;
  class CfgGimel;
    int q;
  endclass
  class GenGimel #(type ONE = int, type TWO = int);
    ONE a;
    TWO b;
  endclass
endpackage

package Pk_Dalet;
  import Pk_Gimel::*;
  class CfgDalet;
    int q;
  endclass

  // q01 : a nested PLAIN class using the OUTER class's type formal.
  class OuterFormal #(type PP = int);
    class InnerUser;
      GenGimel#(PP) q01_outer_formal_from_inner;
      GenGimel#(CfgDalet) q02_inner_concrete;
    endclass
  endclass

  // q03 : a class-scope TYPEDEF as the argument — resolvable, must keep its
  //       entry even in a parameterized class.
  class TypedefArg #(type PP = int);
    typedef bit [3:0] Loc_nib_t;
    GenGimel#(Loc_nib_t) q03_classtypedef_arg;
    GenGimel#(Loc_nib_t, PP) q04_typedef_then_formal;
    GenGimel#(PP, Loc_nib_t) q05_formal_then_typedef;
    GenGimel#(PP, PP) q06_both_formals;
  endclass

  // q07 : the SAME-HOME control (suppressed by the home rule regardless).
  class SameHomeFormal #(type PP = int);
    CfgDalet q07_nonparam;
  endclass
endpackage

import Pk_Gimel::*;
class CfgUnitQ;
  int q;
endclass

// q10 : a class inside a MODULE, using the MODULE's type parameter.
module M_formal_v163 #(type MP = int);
  class ModFormalUser;
    GenGimel#(MP) q10_module_formal_arg;
    GenGimel#(CfgUnitQ) q11_module_concrete;
  endclass
  ModFormalUser u_mfu;
endmodule

// q20 : a class inside an INTERFACE, using the INTERFACE's type parameter.
interface If_formal_v163 #(type IP = int);
  class IfFormalUser;
    GenGimel#(IP) q20_iface_formal_arg;
    GenGimel#(CfgUnitQ) q21_iface_concrete;
  endclass
  IfFormalUser u_ifu;
endinterface

module M_qtop_v163;
  M_formal_v163#(CfgUnitQ) u_m1();
  M_formal_v163#(byte) u_m2();
  If_formal_v163#(CfgUnitQ) u_if1();
  Pk_Dalet::OuterFormal#(Pk_Dalet::CfgDalet)::InnerUser u_ifu;
  Pk_Dalet::TypedefArg#(Pk_Dalet::CfgDalet) u_tda;
  Pk_Dalet::SameHomeFormal#(int) u_shf;
endmodule
