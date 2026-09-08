// r10earl122 arm a1_axis122 — THE AXIS.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// THE HEAD this arm reduces (Earlgrey_0_1/default, tlul_socket_m1.sv):
//
//     for (genvar i = 0 ; i < M ; i++) begin : gen_host_fifo
//       tlul_pkg::tl_h2d_t hreq_fifo_i;        // gen-local struct var
//       logic [IDW-1:0]    shifted_id;         // gen-local, CA-driven
//       assign shifted_id = { ... };
//       assign hreq_fifo_i = '{ ..., a_source: shifted_id, ... };
//                                              // ^^^ THE REFERENCE
//
// golden binds that member-value `ref_obj`'s `Actual_group` to the gen-local
// `logic_var`; we leave it NULL, and `ref_obj::Compare` reads `Actual_group`
// through the SINGULAR `SafeCompare`, so the head prints the GOLDEN POINTEE
// with `RHS: <null>` and hides the owner (own122 named it).
//
// The cells vary the ONE thing the law is about — a BARE gen-local NAME
// standing as an assignment-pattern MEMBER VALUE inside a generate scope —
// against everything that could plausibly be the discriminator: keyed vs
// positional pattern, var vs net vs struct target, same-scope vs ancestor-gen
// vs module-scope operand, pattern nesting depth, and a process instead of a
// continuous assign.
package r122;
  typedef struct packed {
    logic       f_v;
    logic [7:0] f_d;
    logic [3:0] f_s;
  } p_t;
  typedef struct packed {
    logic [7:0] n_d;
    logic       n_v;
  } q_t;
endpackage

module a1_kid122 #(
    parameter int M = 2
) (
    input  logic       clk,
    input  logic [7:0] d_i,
    input  logic [3:0] s_i,
    output logic       v_o,
    output logic [7:0] w_o
);
  logic [7:0] mod_d;          // MODULE-scope operand (the fence half)
  assign mod_d = d_i;

  // ---------------------------------------------------------------- x1
  // THE AXIS CELL, the corpus shape verbatim: a KEYED pattern whose member
  // value is a BARE SAME-SCOPE gen-local that is itself CA-driven.
  for (genvar i = 0; i < M; i++) begin : g1
    r122::p_t   t1;
    logic [7:0] sid1;
    assign sid1 = d_i;
    assign t1 = '{f_v: 1'b1, f_d: sid1, f_s: s_i};
  end

  // ---------------------------------------------------------------- x2
  // Same, but the member value names a MODULE-scope net — the operand-scope
  // half of the axis.
  for (genvar i = 0; i < M; i++) begin : g2
    r122::p_t t2;
    assign t2 = '{f_v: 1'b0, f_d: mod_d, f_s: s_i};
  end

  // ---------------------------------------------------------------- x3
  // POSITIONAL pattern (no tagged_pattern wrapper at all) with the same bare
  // same-scope gen-local operand.
  for (genvar i = 0; i < M; i++) begin : g3
    r122::p_t   t3;
    logic [7:0] sid3;
    assign sid3 = d_i;
    assign t3 = '{1'b1, sid3, s_i};
  end

  // ---------------------------------------------------------------- x4
  // The gen-local operand read from a NESTED pattern (pattern in pattern).
  for (genvar i = 0; i < M; i++) begin : g4
    r122::q_t   inner4;
    logic [7:0] sid4;
    assign sid4 = d_i;
    assign inner4 = '{n_d: sid4, n_v: 1'b1};
  end

  // ---------------------------------------------------------------- x5
  // The operand lives in the ENCLOSING generate scope, read from an inner one.
  for (genvar i = 0; i < M; i++) begin : g5
    logic [7:0] sid5;
    assign sid5 = d_i;
    if (M > 1) begin : g5i
      r122::p_t t5;
      assign t5 = '{f_v: 1'b1, f_d: sid5, f_s: s_i};
    end
  end

  // ---------------------------------------------------------------- x6
  // A PROCESS (always_comb) instead of a continuous assign, same operand.
  for (genvar i = 0; i < M; i++) begin : g6
    r122::p_t   t6;
    logic [7:0] sid6;
    assign sid6 = d_i;
    always_comb t6 = '{f_v: 1'b1, f_d: sid6, f_s: s_i};
  end

  // ---------------------------------------------------------------- x7
  // The pattern's TARGET is a gen-local struct NET (`wire`), operand still the
  // bare same-scope gen-local.
  for (genvar i = 0; i < M; i++) begin : g7
    wire r122::p_t t7;
    logic [7:0]    sid7;
    assign sid7 = d_i;
    assign t7 = '{f_v: 1'b1, f_d: sid7, f_s: s_i};
  end

  // ---------------------------------------------------------------- x8
  // MODULE-scope continuous assign with a keyed pattern over a module-scope
  // operand — the "no generate scope anywhere" control.
  r122::p_t t8;
  assign t8 = '{f_v: 1'b1, f_d: mod_d, f_s: s_i};

  assign v_o = g1[0].t1.f_v ^ g2[0].t2.f_v ^ g3[0].t3.f_v ^ g4[0].inner4.n_v ^
               g5[0].g5i.t5.f_v ^ g6[0].t6.f_v ^ g7[0].t7.f_v ^ t8.f_v;
  assign w_o = g1[0].t1.f_d;
endmodule

// EVERY CELL IS MEASURED INSIDE A CHILD INSTANCE.  At the TOP module the same
// references bind through the unsuppressed path on both binaries, which is why
// this family needed a wrapper to become visible at all (§ genCaSysCallArg-
// Binds22's "child-instance trap").
module a1_axis122 (
    input  logic       clk,
    input  logic [7:0] d_i,
    input  logic [3:0] s_i,
    output logic       v_o,
    output logic [7:0] w_o
);
  a1_kid122 #(.M(2)) u_kid (.clk, .d_i, .s_i, .v_o, .w_o);
endmodule
