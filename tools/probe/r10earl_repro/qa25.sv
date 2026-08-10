// qa25 — THE ENCODING MATRIX for pass-25's frontier: the gen-scope
// WHOLE-RHS enum-const FOLD.  README residue (1) says golden folds
//     assign pmp_req_type[PMP_I] = PMP_ACC_EXEC;      (ibex_core.sv:926:34)
// to ONE loc-less constant {ct=3 sz=2 dec=2'b00} while we keep a ref_obj
// BOUND to a fresh enum_const, and qb23's `assign l_bare = K_C;` shows the
// SAME fold with a DIFFERENT encoding (ct=7 dec "2", K_C = 2'd2).
//
// So MEASURE THE ENCODING FIRST.  Rows E* below read one enum member per
// literal base as the WHOLE RHS of a gen-scope cont_assign:
//   B = 4'b0001   H = 4'h2   O = 4'o3   D = 4'd4   N = 5 (bare decimal)
//   Z = 4'b0000   (the zero value, PMP_ACC_EXEC's own spelling)
// Controls: S* = SELECT LHS over a gen-local UNPACKED ARRAY (the corpus
// shape exactly), P* = module-PORT LHS, T* = ternary BRANCH (must NOT fold),
// Q* = under an OPERATION (must NOT fold), A* = a process (always_comb),
// M* = module level outside any gen scope, R* = QUALIFIED pkg::E spelling.
package qa25_pkg;
  typedef enum logic [3:0] {
    E_B = 4'b0001,
    E_H = 4'h2,
    E_O = 4'o3,
    E_D = 4'd4,
    E_N = 5,
    E_Z = 4'b0000
  } e_t;
endpackage

module qa25_child
  import qa25_pkg::*;
(
    input  logic c,
    output e_t   pb,
    output e_t   po_b,
    output e_t   po_t,
    output e_t   po_q,
    output logic o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12
);
  // M1 — module level, outside every generate scope (control).
  e_t m_bare;
  assign m_bare = E_B;
  assign o1 = (m_bare == E_B);

  if (1) begin : g_enc
    // E* — WHOLE-RHS reads, gen-local PLAIN-NAME LHS, one per base.
    e_t e_b, e_h, e_o, e_d, e_n, e_z;
    assign e_b = E_B;              // based BINARY
    assign e_h = E_H;              // based HEX
    assign e_o = E_O;              // based OCT
    assign e_d = E_D;              // based DECIMAL
    assign e_n = E_N;              // BARE decimal, unsized
    assign e_z = E_Z;              // based binary, value ZERO (corpus shape)

    assign o2 = (e_b == e_h);
    assign o3 = (e_o == e_d);
    assign o4 = (e_n == e_z);
  end

  if (1) begin : g_sel
    // S* — the CORPUS shape: gen-local UNPACKED ARRAY, SELECT LHS.
    e_t   s_arr [4];
    logic s_pk [4];
    assign s_arr[0] = E_Z;         // whole-RHS, select LHS  (ibex_core:926)
    assign s_arr[1] = c ? E_B : E_H;  // ternary, select LHS (ibex_core:929)
    assign s_arr[2] = E_B | E_H;   // operation, select LHS
    assign s_pk[0]  = (s_arr[0] == E_Z);
    assign o5 = s_pk[0];
    assign o6 = (s_arr[1] == s_arr[2]);
  end

  if (1) begin : g_ctl
    // T*/Q* — same scope, NON-whole-RHS spellings that must keep the ref.
    e_t   t_tern;
    e_t   t_op;
    logic t_cmp;
    assign t_tern = c ? E_B : E_H;
    assign t_op   = E_B | E_H;
    assign t_cmp  = (t_tern == E_D);
    assign o7 = t_cmp;
    assign o8 = (t_op == E_O);
  end

  if (1) begin : g_qual
    // R* — the QUALIFIED spelling of the whole-RHS read.
    e_t r_q;
    assign r_q = qa25_pkg::E_B;
    assign o9 = (r_q == E_B);
  end

  if (1) begin : g_proc
    // A* — a PROCESS, whole-RHS on the Lhs of a blocking assign.
    e_t a_p;
    always_comb a_p = E_H;
    assign o10 = (a_p == E_H);
  end

  // P* — module OUTPUT PORT as the cont_assign LHS, inside a gen scope.
  if (1) begin : g_port
    assign po_b = E_B;             // whole-RHS, PORT LHS
    assign po_t = c ? E_B : E_H;
    assign po_q = E_B | E_H;
  end

  // N* — NESTED gen scope, whole-RHS (crosses pass 24's law 1).
  if (1) begin : g_outer
    if (1) begin : g_inner
      e_t n_b;
      assign n_b = E_B;
      assign o11 = (n_b == E_B);
    end
  end

  // F* — FOR-generate, whole-RHS.
  for (genvar k = 0; k < 2; k++) begin : g_for
    e_t f_b;
    assign f_b = E_H;
    assign o12 = (f_b == E_H);
  end

  assign pb = E_D;
endmodule

module qa25
  import qa25_pkg::*;
(
    input  logic c,
    output e_t   pb, po_b, po_t, po_q,
    output logic o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12
);
  qa25_child u_c (.c(c), .pb(pb), .po_b(po_b), .po_t(po_t), .po_q(po_q),
                  .o1(o1), .o2(o2), .o3(o3), .o4(o4), .o5(o5), .o6(o6),
                  .o7(o7), .o8(o8), .o9(o9), .o10(o10), .o11(o11),
                  .o12(o12));
endmodule
