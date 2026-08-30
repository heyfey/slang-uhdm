// r10v163 — arm T: THE LISTING'S CONTENT, on faces the implementer's arm C
// does not spell.  Every cell here is a $unit-class property of a PACKAGE
// generic, so the law fires on all of them and the only question is WHAT the
// listing contains.  Argument kinds, formal/argument arity, value formals in
// every position, named arguments, an empty `#()`, duplicate arguments, a
// scoped typedef argument, a specialization argument, an enum and a packed
// struct argument, and the array/queue/associative/dynamic declarators.
//
// LHS is ALWAYS golden(Surelog); RHS is always ours.

package Pk_Kappa;
  typedef enum bit [1:0] {EK_LO, EK_HI} Enum_k_t;
  typedef struct packed {bit [2:0] a; bit b;} Str_k_t;
  typedef bit [5:0] Vec_k_t;
  class CfgKappa;
    int y;
  endclass
  class TwoT #(type AA = int, type BB = int);
    AA a;
    BB b;
  endclass
  class OneT #(type AA = int);
    AA a;
  endclass
  class ThreeT #(type AA = int, type BB = int, type CC = int);
    AA a;
    BB b;
    CC c;
  endclass
  class ValFirst #(int NN = 1, type AA = int);
    AA a;
  endclass
  class ValOnly #(int NN = 1);
    int a;
  endclass
  class ValLast #(type AA = int, int NN = 3);
    AA a;
  endclass
  class MidVal #(type AA = int, int NN = 2, type BB = int);
    AA a;
    BB b;
  endclass
  class Plain;
    int a;
  endclass
endpackage

import Pk_Kappa::*;

typedef bit [3:0] Nib_u_t;
typedef enum {EU_A, EU_B, EU_C} Enum_u_t;
class CfgUnitK;
  int z;
endclass

class ContentUser;
  TwoT#(int, CfgUnitK)                t01_int_and_class;
  TwoT#(bit [3:0], byte)              t02_packed_and_byte;
  TwoT#(Nib_u_t, Vec_k_t)             t03_unit_td_and_imported_td;
  TwoT#(Pk_Kappa::Vec_k_t, Enum_k_t)  t04_scoped_td_and_enum;
  TwoT#(Str_k_t, OneT#(int))          t05_struct_and_classspec;
  OneT#(int)                          t06_single_of_single;
  TwoT#(int)                          t07_one_of_two;
  ThreeT#(int, byte)                  t08_two_of_three;
  ValFirst#(4, CfgUnitK)              t09_value_then_type;
  ValFirst#(2 + 3, int)               t10_expr_value_then_type;
  ValLast#(CfgUnitK, 6)               t11_type_then_value;
  MidVal#(int, 7, byte)               t12_type_value_type;
  ValOnly#(9)                         t13_value_only;
  TwoT#(.AA(int), .BB(byte))          t14_named_both;
  TwoT#(int, int)                     t15_duplicate_args;
  TwoT#(Enum_u_t, Enum_k_t)           t16_two_enums;
  TwoT                                t17_bare_default;
  Plain                               t18_nonparam;
  OneT#(logic signed [7:0])           t19_signed_vector;
  OneT#(CfgUnitK)                     t20_class_arg_only;
  TwoT#(int, CfgUnitK)                t30_fixed [3];
  TwoT#(int, CfgUnitK)                t31_queue [$];
  TwoT#(int, CfgUnitK)                t32_dyn [];
  TwoT#(int, CfgUnitK)                t33_assoc [string];
endclass

module M_content_v163;
  ContentUser u_cu;
  initial begin
    u_cu = new();
  end
endmodule
