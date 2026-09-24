// v136 arm G — type parameters, specializations, inheritance of a packed-struct
// property, and 3 instances of each home.
package Pk_Param;
  typedef struct packed { bit [7:0] pA; bit [7:0] pB; } paramSpan_S;
  typedef union  packed { bit [3:0] pU; bit [3:0] pV; } paramWrap_U;
  typedef struct { int uA; int uB; }                    paramLoose_S;

  class Generic #(type TF = int);
    TF h01_tp;
  endclass

  typedef Generic#(paramSpan_S) specStruct_t;
  typedef Generic#(paramWrap_U) specUnion_t;
  typedef Generic#(paramLoose_S) specLoose_t;
  typedef Generic#(bit [7:0])   specVec_t;

  class SpecHome;
    specStruct_t h02_specS;
    specUnion_t  h03_specU;
    specLoose_t  h04_specL;
    specVec_t    h05_specV;
  endclass

  class BaseWithSpan;
    paramSpan_S h06_inherited;
    protected paramWrap_U h07_protInherited;
  endclass

  class MidExt extends BaseWithSpan;
    paramSpan_S h08_mid;
  endclass

  class LeafExt extends MidExt;
    paramWrap_U h09_leaf;
  endclass
endpackage

module mod_param_top;
  import Pk_Param::*;
  LeafExt  u_leaf_one;
  LeafExt  u_leaf_two;
  LeafExt  u_leaf_three;
  SpecHome u_spec;
  initial begin
    u_leaf_one = new();
    u_leaf_two = new();
    u_leaf_three = new();
    u_spec = new();
  end
endmodule
