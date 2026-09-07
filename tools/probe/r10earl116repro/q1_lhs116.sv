// r10earl116 arm q1_lhs116 — THE Lhs-SHAPE AXIS.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Every cell is a KEYED (structured) assignment pattern in a continuous assign
// inside a generate scope — the corpus carrier (r10earl115's `p1_pos115`, whose
// shape this arm copies so the Lhs is the ONLY thing that varies).  What varies
// is the SHAPE OF THE Lhs, which is the only thing `cont_assign::DeepClone`
// (~/git-repos/UHDM/templates/clone_tree.cpp:803-820) looks at before deciding
// whether to run `ExprEval::flattenPatternAssignments` over the Rhs:
//
//     if (ref_obj* ro = any_cast<ref_obj*>(lhs))
//       if (struct_var* stv = ro->Actual_group<struct_var>())
//         ... eval.flattenPatternAssignments(...)
//
// `any_cast` is IS-A, and `bit_select`/`var_select` derive from `ref_obj`
// (~/.local/include/uhdm/bit_select.h:41), so the FIRST test passes for a
// select Lhs and the SECOND fails: a select's `Actual_group` is the ARRAY.
//
//   c1  whole-name gen-local struct VAR      -- the MUST-STAY-FLAT floor
//   c2  SELECT on a MODULE-scope unpacked array of structs (the corpus shape)
//   c3  SELECT on a GEN-LOCAL unpacked array of structs
//   c4  MEMBER Lhs (a packed sub-struct of a gen-local struct var)
//   c5  whole-name gen-local struct NET (`wire`) -- struct_net, not struct_var
//   c6  whole-name MODULE-scope struct var written from INSIDE a gen scope
//       (= r10earl115's p3 x2 fence: golden BINDS its path elements there)
//   c7  SELECT with a nested index on a 2-D unpacked array of structs
package q116p;
  typedef enum logic [2:0] {OpA = 3'h0, OpB = 3'h4} op_e;
  typedef struct packed {
    logic [3:0] f0;
    logic [3:0] f1;
  } sub_t;
  typedef struct packed {
    logic       a_valid;
    op_e        a_opcode;
    logic [7:0] a_data;
  } h2d_t;
  typedef struct packed {
    logic v;
    sub_t lo;
  } outer_t;
endpackage

module q1_lhs116 #(
    parameter int M = 3
) (
    input  logic       clk,
    input  q116p::h2d_t two_i[M],
    input  logic [7:0] d_i,
    output logic       v_o
);
  q116p::h2d_t marr [M];       // c2 target
  q116p::h2d_t marr2[M][2];    // c7 target
  q116p::h2d_t mvar;           // c6 target

  // c1  WHOLE-NAME gen-local struct var -- golden FLATTENS (must stay).
  for (genvar i = 0; i < M; i++) begin : gen_c1
    q116p::h2d_t c1_t;
    assign c1_t = '{a_valid: two_i[i].a_valid, a_opcode: q116p::OpA, a_data: d_i};
  end

  // c2  SELECT Lhs on a MODULE-scope unpacked array -- the corpus head shape.
  for (genvar i = 0; i < M; i++) begin : gen_c2
    assign marr[i] = '{a_valid: two_i[i].a_valid, a_opcode: q116p::OpA, a_data: d_i};
  end

  // c3  SELECT Lhs on a GEN-LOCAL unpacked array.
  for (genvar i = 0; i < M; i++) begin : gen_c3
    q116p::h2d_t garr[2];
    assign garr[0] = '{a_valid: two_i[i].a_valid, a_opcode: q116p::OpA, a_data: d_i};
  end

  // c4  MEMBER Lhs: a packed sub-struct of a gen-local struct var.
  for (genvar i = 0; i < M; i++) begin : gen_c4
    q116p::outer_t c4_t;
    assign c4_t.lo = '{f0: two_i[i].a_data[3:0], f1: two_i[i].a_data[7:4]};
  end

  // c5  WHOLE-NAME gen-local struct NET.
  for (genvar i = 0; i < M; i++) begin : gen_c5
    wire q116p::h2d_t c5_t;
    assign c5_t = '{a_valid: two_i[i].a_valid, a_opcode: q116p::OpA, a_data: d_i};
  end

  // c6  WHOLE-NAME Lhs, target declared in the MODULE BODY, written from a
  //     generate scope -- r10earl115's fence (d): golden BINDS there.
  if (M == 3) begin : gen_c6
    assign mvar = '{a_valid: two_i[0].a_valid, a_opcode: q116p::OpA, a_data: d_i};
  end

  // c7  SELECT with a nested index.
  for (genvar i = 0; i < M; i++) begin : gen_c7
    assign marr2[i][0] = '{a_valid: two_i[i].a_valid, a_opcode: q116p::OpA, a_data: d_i};
  end

  assign v_o = marr[0].a_valid ^ marr2[0][0].a_valid ^ mvar.a_valid;
endmodule
