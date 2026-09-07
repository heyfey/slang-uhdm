// r10uvm187 GRID — the per-parameter NAMED TYPESPEC CLONE of a bare typedef,
// across scope x typedef kind x parameter/localparam x DEF/ELAB view.
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
package gp187;
  parameter int NB = 12;
  typedef int            i_t;      // scalar int typedef      <-- the head's face
  typedef byte           by_t;     // scalar byte typedef
  typedef shortint       si_t;     // scalar shortint typedef
  typedef longint        li_t;     // scalar longint typedef
  typedef integer        ig_t;     // scalar integer typedef
  typedef bit            b1_t;     // scalar bit typedef
  typedef logic          l1_t;     // scalar logic typedef
  typedef bit   [7:0]    b8_t;     // RANGED bit typedef
  typedef logic [7:0]    l8_t;     // RANGED logic typedef
  typedef bit   [NB-1:0] bf_t;     // RANGED bit typedef, PARAMETER bound
  typedef string         s_t;      // string typedef
  typedef real           r_t;      // real typedef
  typedef time           t_t;      // time typedef
  typedef enum bit [1:0] { EA, EB } e_t;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } st_t;
  typedef i_t            i2_t;     // typedef OF a scalar int typedef

  parameter  i_t   P_I    = 7;
  localparam i_t   L_I    = 8;
  parameter  by_t  P_BY   = 3;
  localparam by_t  L_BY   = 4;
  parameter  si_t  P_SI   = 5;
  parameter  li_t  P_LI   = 6;
  parameter  ig_t  P_IG   = 9;
  parameter  b1_t  P_B1   = 1'b1;
  parameter  l1_t  P_L1   = 1'b0;
  parameter  b8_t  P_B8   = 8'hAA;
  localparam b8_t  L_B8   = 8'h55;
  parameter  l8_t  P_L8   = 8'h0F;
  parameter  bf_t  P_BF   = (1<<3);
  parameter  s_t   P_S    = "hi";
  parameter  r_t   P_R    = 1.5;
  parameter  t_t   P_T    = 5;
  parameter  e_t   P_E    = EA;
  parameter  st_t  P_ST   = 8'h12;
  parameter  i2_t  P_I2   = 11;
  parameter  int   P_RAWI = 12;     // written builtin, NOT a typedef
  parameter        P_UNT  = 13;     // untyped
endpackage

package qp187;
  typedef int qi_t;
endpackage

// $unit home is NOT gridded: `typedef int` at $unit is a PRE-EXISTING
// slang-uhdm decline ("unsupported constructs: typedef target:
// PredefinedIntegerType", rc=4) on BOTH binaries -- an arm that cannot be
// scored is not an arm.  Recorded as a residue, untouched by this pass.

module m187 ();
  typedef int mi_t;
  typedef bit [7:0] mb_t;
  parameter  mi_t  MP_I  = 31;      // module home, own scalar int typedef
  localparam mi_t  ML_I  = 32;
  parameter  mb_t  MP_B  = 8'h11;
  parameter  gp187::i_t MQ_I = 33;  // module home, QUALIFIED pkg int typedef
  parameter  qp187::qi_t MQQ  = 34;
  if (1) begin : g
    parameter  mi_t GP_I = 35;
    localparam mi_t GL_I = 36;
  end
  class Cm;
    localparam mi_t CL_I = 37;      // class in module, module typedef
  endclass
endmodule

package cp187;
  typedef int ci_t;
  typedef bit [7:0] cb_t;
  class C187;
    typedef int cli_t;              // class-scope int typedef
    localparam ci_t  CP_I  = 41;    // class home, package typedef
    localparam cli_t CP_CI = 42;    // class home, class typedef
    localparam cb_t  CP_B  = 8'h43;
  endclass
endpackage

module top187 ();
  m187 u ();
endmodule
