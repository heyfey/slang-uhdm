// qb25 — THE UNMEASURED HALVES of pass-25 law 1 (the gen-scope WHOLE-RHS
// enum-const fold measured on qa25).  qa25 only ever read a PACKAGE enum with
// an EXPLICIT base from a CHILD instance's gen scope.  Rows here vary exactly
// the four things it held fixed:
//   U*  a $unit-scope enum        (Scr1SvTests is the standing counter-witness
//                                  for BINDING; is it also one for FOLDING?)
//   L*  a MODULE-LOCAL typedef enum (the tlul_adapter_sram req_op_e family)
//   I*  an enum with an IMPLICIT base (`typedef enum { .. }`)
//   T*  the SAME package read from a TOP-MODULE gen scope, not a child's
//   O*  LHS is a MODULE-level signal, not a gen local
//   A*  LHS is an ANCESTOR gen scope's local
//   V*  an INTERFACE gen scope
typedef enum logic [3:0] { U_A = 4'b0001, U_B = 4'h2 } u_t;   // $unit scope

package qb25_pkg;
  typedef enum logic [3:0] { P_A = 4'b0001, P_B = 4'h2 } p_t;
  typedef enum { I_A, I_B } i_t;                                // implicit base
endpackage

interface qb25_if;
  import qb25_pkg::*;
  logic v;
  // V* — an INTERFACE gen scope: does the fold reach here, or is it a
  // module-only rule the way the module-level pkgEnumRhs fold is?
  if (1) begin : g_iv
    p_t   v_l;
    logic v_m;
    assign v_l = P_A;
    assign v_m = 1'b1;
  end
endinterface

module qb25_child
  import qb25_pkg::*;
(
    input  logic c,
    output logic o1, o2, o3, o4, o5, o6, o7
);
  typedef enum logic [3:0] { L_A = 4'b0001, L_B = 4'h2 } l_t;

  logic [3:0] mod_sig;      // a MODULE-level signal, driven from a gen scope
  u_t         mod_u [2];

  if (1) begin : g_unit
    u_t u_x;
    assign u_x = U_A;            // $unit enum, whole RHS, gen-local LHS
    assign o1  = (u_x == U_A);
  end

  if (1) begin : g_loc
    l_t l_x;
    assign l_x = L_A;            // MODULE-LOCAL enum, whole RHS
    assign o2  = (l_x == L_A);
  end

  if (1) begin : g_imp
    i_t i_x;
    assign i_x = I_B;            // IMPLICIT-base package enum, whole RHS
    assign o3  = (i_x == I_B);
  end

  if (1) begin : g_modlhs
    assign mod_sig = P_B;        // MODULE-level LHS, whole RHS
    assign o4      = (mod_sig == 4'h2);
  end

  if (1) begin : g_anc
    logic [3:0] a_x;
    if (1) begin : g_anc_in
      assign a_x = P_A;          // ANCESTOR gen scope's local as LHS
    end
    assign o5 = (a_x == 4'h1);
  end

  // A for-generate whose body assigns a MODULE-level signal.
  for (genvar k = 0; k < 2; k++) begin : g_fmod
    assign mod_u[k] = U_B;
  end
  assign o6 = (mod_u[0] == U_B);
  assign o7 = c;
endmodule

module qb25
  import qb25_pkg::*;
(
    input  logic c,
    output logic o1, o2, o3, o4, o5, o6, o7,
    output logic t1, t2, t3
);
  qb25_child u_c (.c(c), .o1(o1), .o2(o2), .o3(o3), .o4(o4), .o5(o5),
                  .o6(o6), .o7(o7));

  // T* — the SAME shapes in the TOP module's own gen scopes.
  if (1) begin : t_top
    p_t t_x;
    assign t_x = P_A;            // TOP-module gen scope, whole RHS
    assign t1  = (t_x == P_A);
  end

  for (genvar k = 0; k < 2; k++) begin : t_for
    p_t t_f;
    assign t_f = P_B;
    if (k == 0) assign t2 = (t_f == P_B);
  end

  if (1) begin : t_out
    if (1) begin : t_in
      p_t t_n;
      assign t_n = P_A;          // TOP-module NESTED gen scope
      assign t3  = (t_n == P_A);
    end
  end

  qb25_if u_if ();
endmodule
