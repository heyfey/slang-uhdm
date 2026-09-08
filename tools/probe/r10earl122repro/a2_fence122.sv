// r10earl122 arm a2_fence122 — THE FENCE.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// EVERY CELL IS INSIDE A CHILD INSTANCE, because the whole family is a
// child-instance gap: at the TOP module the reference binds through the
// unsuppressed path and none of this is visible (§ genCaSysCallArgBinds22's
// own note, "five passes of top-module witnesses never saw it").
//
// The law under test descends § genCaOpDeepBindGenLocal20's `deep20` walk
// through a `tagged_pattern` wrapper.  These are the cells the walk MUST NOT
// change, one per reason:
//
//   f1  Lhs is an ELEMENT SELECT of a gen-local array (§ genCaSelLhsDeep-
//       BindGenLocal23 turns the walk on for selects too — so the wrapper
//       descent reaches here, and golden's answer decides whether that is
//       right)
//   f2  Lhs is a MEMBER ACCESS of a gen-local struct (same clause)
//   f3  Lhs is a MODULE-scope signal written from the gen scope — the walk is
//       off entirely (`lhsGenLocal20` false), and golden flattens the pattern
//       there anyway (§ genCaLhsGenLocal113 / § genCaPatKeepTagDefView121)
//   f4  the operand is a gen-local NET (`wire`) — `deep20`'s own leaf filter
//       returns on every net kind and must keep doing so
//   f5  the operand lives in the ANCESTOR gen scope, read from an inner block
//       — `deep20`'s member scan is over THIS block only
//   f6  a POSITIONAL pattern (no wrapper at all) — the pre-existing path, and
//       the control that says the descent is what changed anything
//   f7  the Lhs name is SHADOWED by a net one module up
//       (§ genCaAncestorNetShadowUnbinds98 turns the walk back OFF)
//   f8  a REPLICATED pattern operand
//   f9  a gen-scope PROCESS (always_comb) with a keyed pattern — not a
//       cont_assign, so `deep20` never runs
package r122f;
  typedef struct packed {
    logic       f_v;
    logic [7:0] f_d;
  } s_t;
endpackage

module a2_kid122 #(
    parameter int M = 2
) (
    input  logic       clk,
    input  logic [7:0] d_i,
    output logic [7:0] o_o
);
  logic [7:0]   mod_d;
  r122f::s_t    mod_t;
  logic [7:0]   shadowed;      // f7's shadow lives in a2_fence122, not here
  assign mod_d = d_i;

  // f1 — element-select Lhs of a gen-local array
  for (genvar i = 0; i < M; i++) begin : gf1
    r122f::s_t  arr1 [2];
    logic [7:0] v1;
    assign v1 = d_i;
    assign arr1[0] = '{f_v: 1'b1, f_d: v1};
  end

  // f2 — member-access Lhs of a gen-local struct
  for (genvar i = 0; i < M; i++) begin : gf2
    r122f::s_t  t2;
    logic [7:0] v2;
    assign v2 = d_i;
    assign t2.f_d = v2;
  end

  // f3 — MODULE-scope target written from the gen scope
  for (genvar i = 0; i < M; i++) begin : gf3
    logic [7:0] v3;
    assign v3 = d_i;
    assign mod_t = '{f_v: 1'b1, f_d: v3};
  end

  // f4 — the operand is a gen-local NET
  for (genvar i = 0; i < M; i++) begin : gf4
    r122f::s_t t4;
    wire [7:0] v4;
    assign v4 = d_i;
    assign t4 = '{f_v: 1'b1, f_d: v4};
  end

  // f5 — the operand lives in the ANCESTOR gen scope
  for (genvar i = 0; i < M; i++) begin : gf5
    logic [7:0] v5;
    assign v5 = d_i;
    if (M > 1) begin : gf5i
      r122f::s_t t5;
      assign t5 = '{f_v: 1'b1, f_d: v5};
    end
  end

  // f6 — POSITIONAL pattern, no wrapper
  for (genvar i = 0; i < M; i++) begin : gf6
    r122f::s_t  t6;
    logic [7:0] v6;
    assign v6 = d_i;
    assign t6 = '{1'b1, v6};
  end

  // f7 — the Lhs name is shadowed by a net one module up
  for (genvar i = 0; i < M; i++) begin : gf7
    r122f::s_t  shadow_t;
    logic [7:0] v7;
    assign v7 = d_i;
    assign shadow_t = '{f_v: 1'b1, f_d: v7};
  end

  // f8 — REPLICATED pattern operand
  for (genvar i = 0; i < M; i++) begin : gf8
    logic [15:0] t8;
    logic [7:0]  v8;
    assign v8 = d_i;
    assign t8 = {2{v8}};
  end

  // f9 — a PROCESS, not a continuous assign
  for (genvar i = 0; i < M; i++) begin : gf9
    r122f::s_t  t9;
    logic [7:0] v9;
    assign v9 = d_i;
    always_comb t9 = '{f_v: 1'b1, f_d: v9};
  end

  assign o_o = gf1[0].arr1[0].f_d ^ gf2[0].t2.f_d ^ mod_t.f_d ^ gf4[0].t4.f_d ^
               gf5[0].gf5i.t5.f_d ^ gf6[0].t6.f_d ^ gf7[0].shadow_t.f_d ^
               gf8[0].t8[7:0] ^ gf9[0].t9.f_d ^ shadowed;
endmodule

module a2_fence122 (
    input  logic       clk,
    input  logic [7:0] d_i,
    output logic [7:0] o_o
);
  // f7's shadow: a NET of the same name as the gen-local Lhs, one module up.
  wire r122f::s_t shadow_t;
  assign shadow_t = '{f_v: 1'b0, f_d: 8'h00};
  a2_kid122 #(.M(2)) u_kid (.clk, .d_i, .o_o);
endmodule
