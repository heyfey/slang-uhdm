// r10v163 (adversarial verification of r10uvm163) — arm S: THE SITES.
//
// § classPropSpecForeignPkgHome163 fires on `siteKind53 == ClassType`, i.e.
// on any declaration whose IMMEDIATE parent scope is a ClassType.  That is a
// broader set than "a class property": a class-scope TYPEDEF, a class-scope
// type localparam and a class-scope parameter also sit directly in a
// ClassType.  This arm asks golden what each of those sites does when the
// generic's home package is NOT the declaring class's home package, and
// crosses it with every property FACE (static / rand / local / protected /
// two names on one declaration / two declarations of one specialization / two
// specializations of one generic) and with the non-class sites the pass says
// it leaves alone (package variable, module variable, $unit variable, method
// formal, method local, interface class, program class).
//
// Naming is deliberately NOT the implementer's a_/b_/c_ scheme and the cells
// are NOT in home order.
// LHS is ALWAYS golden(Surelog); RHS is always ours.

package Pk_Zeta;
  class CfgZeta;
    int w;
  endclass
  class GenZeta #(type FIRST = int, type SECOND = int);
    FIRST f;
    SECOND s;
  endclass
  // s01/s02 : the SAME-HOME controls (probe 3 hits) — must stay listing-free.
  class SameHomeUser;
    GenZeta#(CfgZeta) s01_prop_samehome;
    typedef GenZeta#(CfgZeta) S02_td_samehome_t;
    S02_td_samehome_t s02_use;
    static GenZeta#(CfgZeta) s03_static_samehome;
  endclass
endpackage

package Pk_Omega;
  import Pk_Zeta::*;
  class CfgOmega;
    int w;
  endclass
  // The FOREIGN-home faces: every one of these is a ClassType-parented
  // declaration of an unqualified `GenZeta#(...)`.
  class ForeignUser;
    GenZeta#(CfgOmega) s10_prop_foreign;
    typedef GenZeta#(CfgOmega) S11_td_foreign_t;   // a class-scope TYPEDEF site
    S11_td_foreign_t s11_use;
    localparam type S12_tdparam = GenZeta#(CfgOmega);  // a class-scope TYPE param
    S12_tdparam s12_use;
    static GenZeta#(CfgOmega) s13_static;
    rand GenZeta#(CfgOmega) s14_rand;
    local GenZeta#(CfgOmega) s15_local;
    protected GenZeta#(CfgOmega) s16_prot;
    GenZeta#(CfgOmega) s17_twin_a, s17_twin_b;     // ONE declaration, TWO names
    GenZeta#(CfgOmega) s18_second;                 // the SAME specialization again
    GenZeta#(int) s19_other_spec;                  // another spec of one generic
    function void mth(GenZeta#(CfgOmega) s20_formal);
      GenZeta#(CfgOmega) s21_methlocal;
      s21_methlocal = s20_formal;
      s10_prop_foreign = s21_methlocal;
    endfunction
  endclass
  // s30 : a PACKAGE VARIABLE of the foreign generic (the pass says: untouched).
  GenZeta#(CfgOmega) s30_pkgvar;
  // s31 : a class whose OWN generic-ness is irrelevant — a parameterized
  //       declaring class holding a foreign generic, the argument being its
  //       own type formal.
  class ParamUser #(type PP = int);
    GenZeta#(PP) s31_arg_is_own_formal;
  endclass
  class ParamUserUse;
    ParamUser#(CfgOmega) s32_spec_of_local_generic;
  endclass
endpackage

// ---------------------------------------------------------------- $unit
import Pk_Zeta::*;
class CfgUnitZ;
  int z;
endclass

class UnitUser;
  GenZeta#(CfgUnitZ) s40_unitcls_prop;
  typedef GenZeta#(CfgUnitZ) S41_td_unitcls_t;
  S41_td_unitcls_t s41_use;
endclass

GenZeta#(CfgUnitZ) s45_unitvar;               // a $unit VARIABLE

// --------------------------------------------------------------- module
module M_hold_v163;
  GenZeta#(CfgUnitZ) s50_modvar;
  GenZeta#(CfgUnitZ) s51_modvar_new = new();
  class InModUser;
    GenZeta#(CfgUnitZ) s52_modcls_prop;
    typedef GenZeta#(CfgUnitZ) S53_td_modcls_t;
    S53_td_modcls_t s53_use;
  endclass
  InModUser s54_inst;
  UnitUser s55_unit_inst;
  Pk_Omega::ForeignUser s56_foreign_inst;
  Pk_Zeta::SameHomeUser s57_same_inst;
  Pk_Omega::ParamUserUse s58_paramuser_inst;
endmodule

// ------------------------------------------------------- interface / program
interface If_v163;
  class InIfUser;
    GenZeta#(CfgUnitZ) s60_ifcls_prop;
  endclass
  InIfUser s61_inst;
endinterface

program Pg_v163;
  class InPgUser;
    GenZeta#(CfgUnitZ) s70_pgcls_prop;
  endclass
  InPgUser s71_inst;
  initial begin
    s71_inst = new();
  end
endprogram

// three instances of the holder module + one interface + one program, so the
// ELABORATED view has more than one copy of every module cell.
module M_top_v163;
  M_hold_v163 u_one();
  M_hold_v163 u_two();
  M_hold_v163 u_three();
  If_v163 u_if();
  Pg_v163 u_pg();
endmodule
