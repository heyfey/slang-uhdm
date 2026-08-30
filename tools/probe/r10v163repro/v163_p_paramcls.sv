// r10v163 — arm P: THE REGRESSION AXIS the pass never crossed — a declaring
// class that is ITSELF PARAMETERIZED, and an argument that names one of its
// own type formals.  Arm S cell `s31_arg_is_own_formal` reads golden=NO
// LISTING, pristine=NO LISTING, patched=ONE ENTRY, i.e. pristine-right ->
// patched-wrong.  This arm separates the two candidate causes:
//
//   (A) the DECLARING class is parameterized      -> p02 must be suppressed
//   (B) the written ARGUMENT names a type formal  -> p02 must be listed
//
// and then crosses the winner with the value-formal, nested, $unit and
// multi-specialization faces.
//
// LHS is ALWAYS golden(Surelog); RHS is always ours.

package Pk_Alef;
  class CfgAlef;
    int q;
  endclass
  class GenAlef #(type ONE = int, type TWO = int);
    ONE a;
    TWO b;
  endclass
endpackage

package Pk_Bet;
  import Pk_Alef::*;
  class CfgBet;
    int q;
  endclass

  // p01 : the CONTROL — a PLAIN declaring class, concrete argument.
  class PlainBet;
    GenAlef#(CfgBet) p01_plain_concrete;
  endclass

  // p02 : a TYPE-parameterized declaring class, CONCRETE argument.
  class TypeParamBet #(type PP = int);
    GenAlef#(CfgBet) p02_typeparamcls_concrete;
  endclass

  // p03 : the regression cell — the argument NAMES the declaring class's own
  //       type formal.
  class ArgIsFormalBet #(type PP = int);
    GenAlef#(PP) p03_arg_is_formal;
  endclass

  // p04 : a VALUE-parameterized declaring class, concrete argument.
  class ValParamBet #(int NN = 1);
    GenAlef#(CfgBet) p04_valueparamcls_concrete;
  endclass

  // p05 : both — one concrete argument and one formal argument.
  class MixedArgBet #(type PP = int);
    GenAlef#(CfgBet, PP) p05_concrete_then_formal;
    GenAlef#(PP, CfgBet) p06_formal_then_concrete;
  endclass

  // p07 : a PLAIN class NESTED inside a parameterized class.
  class OuterParamBet #(type PP = int);
    class InnerPlainBet;
      GenAlef#(CfgBet) p07_plaininner_of_paramouter;
    endclass
  endclass

  // p08 : a value formal used as the VALUE argument of a value formal.
  class ValArgBet #(int NN = 2);
    GenAlef#(CfgBet) p08_second;
  endclass
endpackage

// ------------------------------------------------------------------- $unit
import Pk_Alef::*;
class CfgUnitP;
  int q;
endclass

class UnitTypeParam #(type PP = int);
  GenAlef#(CfgUnitP) p10_unit_paramcls_concrete;
  GenAlef#(PP) p11_unit_arg_is_formal;
endclass

class UnitPlain;
  GenAlef#(CfgUnitP) p12_unit_plain_concrete;
endclass

module M_param_v163;
  Pk_Bet::PlainBet u_pb;
  Pk_Bet::TypeParamBet#(Pk_Bet::CfgBet) u_tpb;
  Pk_Bet::TypeParamBet#(int) u_tpb2;
  Pk_Bet::ArgIsFormalBet#(Pk_Bet::CfgBet) u_aifb;
  Pk_Bet::ArgIsFormalBet#(byte) u_aifb2;
  Pk_Bet::ValParamBet#(3) u_vpb;
  Pk_Bet::MixedArgBet#(Pk_Bet::CfgBet) u_mab;
  Pk_Bet::OuterParamBet#(int)::InnerPlainBet u_ipb;
  Pk_Bet::ValArgBet#(5) u_vab;
  UnitTypeParam#(CfgUnitP) u_utp;
  UnitPlain u_up;
endmodule
