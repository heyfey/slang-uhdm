// r10v163 — arm N: THE HOME WALK.  The pass's predicate walks THROUGH
// enclosing ClassTypes to find the declaring class's home PACKAGE and stops at
// anything else.  This arm crosses nesting DEPTH (1, 2, 3 classes deep) with
// the home relation, adds the self-typed property, the argument that names the
// declaring class, a generic that is NESTED IN A CLASS (which the §53
// predicate never sees, because its parent scope is not a Package), and a
// cross-package inheritance chain.
//
// LHS is ALWAYS golden(Surelog); RHS is always ours.

package Pk_Nu;
  class CfgNu;
    int q;
  endclass
  class GenNu #(type TT = int);
    TT t;
  endclass
  class BaseNu;
    int b;
  endclass
  // depth 3 in the generic's OWN package — probe 3 spells `Pk_Nu::GenNu`
  // through the CONTAINER, so all three depths must stay listing-free.
  class OuterNu;
    GenNu#(CfgNu) n01_depth1_samepkg;
    class MidNu;
      GenNu#(CfgNu) n02_depth2_samepkg;
      class InnerNu;
        GenNu#(CfgNu) n03_depth3_samepkg;
      endclass
    endclass
    MidNu m;
  endclass
  // a generic NESTED IN A CLASS: its parent scope is a ClassType, not a
  // Package, so neither §53 nor §163 can see it.
  class NestHostNu;
    class InnerGenNu #(type TT = int);
      TT t;
    endclass
    InnerGenNu#(CfgNu) n04_nested_generic;
  endclass
  // a self-typed property, same home.
  class SelfNu #(type TT = int);
    SelfNu#(int) n05_selftyped;
  endclass
endpackage

package Pk_Xi;
  import Pk_Nu::*;
  class CfgXi;
    int q;
  endclass
  // the same three depths, one package over.
  class OuterXi;
    GenNu#(CfgXi) n11_depth1_crosspkg;
    class MidXi;
      GenNu#(CfgXi) n12_depth2_crosspkg;
      class InnerXi;
        GenNu#(CfgXi) n13_depth3_crosspkg;
      endclass
    endclass
    MidXi m;
  endclass
  // the argument names the DECLARING class itself, cross-package.
  class SelfArgXi;
    GenNu#(SelfArgXi) n14_arg_is_self;
  endclass
  // a class EXTENDING a foreign base, holding the foreign generic.
  class DerivedXi extends BaseNu;
    GenNu#(CfgXi) n15_in_derived;
  endclass
endpackage

// a $unit class three deep, holding the package generic.
import Pk_Nu::*;
class CfgUnitN;
  int q;
endclass
class OuterUnitN;
  class MidUnitN;
    class InnerUnitN;
      GenNu#(CfgUnitN) n21_depth3_unit;
    endclass
  endclass
  MidUnitN m;
endclass

module M_nest_v163;
  // a class three deep inside a MODULE.
  class OuterModN;
    class MidModN;
      class InnerModN;
        GenNu#(CfgUnitN) n31_depth3_mod;
      endclass
    endclass
    MidModN m;
  endclass
  OuterModN u_om;
  OuterModN::MidModN::InnerModN u_imn;
  OuterUnitN u_ou;
  OuterUnitN::MidUnitN::InnerUnitN u_iun;
  Pk_Nu::OuterNu u_on;
  Pk_Nu::OuterNu::MidNu::InnerNu u_inn;
  Pk_Xi::OuterXi u_ox;
  Pk_Xi::OuterXi::MidXi::InnerXi u_ixi;
  Pk_Xi::SelfArgXi u_sa;
  Pk_Xi::DerivedXi u_dx;
  Pk_Nu::NestHostNu u_nh;
  Pk_Nu::SelfNu#(int) u_sn;
endmodule
