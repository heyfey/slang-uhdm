// r10earl121 arm a1_axis121 — THE AXIS of § `genCaPatKeepTagDefView121`.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Every cell is a KEYED (structured) assignment pattern in a CONTINUOUS ASSIGN
// inside a GENERATE scope whose TARGET is declared in that same generate block
// by its WHOLE NAME — the one shape whose flatten is performed by
// `cont_assign::DeepClone` (UHDM templates/clone_tree.cpp:803-820), i.e. by
// UHDM's `ElaboratorListener`, and therefore ONLY under `-elabuhdm`.  Surelog's
// own writer cannot flatten it: `UhdmWriter::writeCont_assign`'s flatten sits
// inside `if (tps)` and `tps` comes from `bindVariable`
// (CompileStmt.cpp:3089-3148), whose scope walk has NO `gen_scope` case.
//
// So in the DEFAULT view golden keeps the `tagged_pattern` wrappers that
// `CompileHelper::compileAssignmentPattern` (CompileExpression.cpp:3782-3833)
// minted, and in the `-elabuhdm` view it does not.  BUILD THIS ARM BOTH WAYS:
//
//   ~/git-repos/Surelog/build/bin/surelog -parse            a1_axis121.sv
//   ~/git-repos/Surelog/build/bin/surelog -parse -elabuhdm  a1_axis121.sv
//
// (the harness Surelog, spelled in full — r10earl120's residue R4: the shell
// `surelog` alias is a DIFFERENT build whose Earlgrey databases crash the dump
// tools.)
//
// WHAT VARIES ACROSS CELLS IS THE MEMBER-VALUE FORM, because
// `ExprEval::recursiveFlattening` (UHDM ExprEval.cpp:652-745) switches on the
// TAG typespec kind and a bare member-name key always produces a
// `string_typespec`, whose arm unwraps everything except a nested
// tagged-`default` operation.  If the member form mattered, it would show here.
//
//   x1  gen-local struct VAR  — six member forms in ONE pattern
//   x2  a SECOND gen-local struct VAR in the same block (two carriers, one scope)
//   x3  the same shape at a SECOND generate depth (a nested for inside a for)
//   x4  the target declared in the OUTER block, written from the INNER one
//   x5  the same pattern written in a generate IF block rather than a for
//
// The gen-local struct NET (`wire`) flavour of x1 lives in `a3_net121.sv`, on
// its own, because that declaration carries a PRE-EXISTING and unrelated
// difference (golden lists a `wire`-typed struct under the gen scope's
// `vpiVariables` as a `struct_var`; we emit no `Variables` vector there at all)
// which would otherwise mask this arm's verdict.  Residue R2.
package p121;
  typedef enum logic [2:0] {OpA = 3'h0, OpB = 3'h4} op_e;
  typedef struct packed {
    logic [3:0] f0;
    logic [3:0] f1;
  } sub_t;
  typedef struct packed {
    logic       m_id;     // member form: simple identifier
    logic [7:0] m_hp;     // member form: hierarchical path (a.b)
    logic [7:0] m_idx;    // member form: indexed select (a[i])
    logic [7:0] m_lit;    // member form: literal
    op_e        m_enum;   // member form: enum constant
    sub_t       m_nest;   // member form: NESTED assignment pattern
  } wide_t;
endpackage

module a1_axis121 #(
    parameter int M = 3
) (
    input  logic        clk,
    input  p121::wide_t two_i [M],
    input  logic [7:0]  d_i,
    input  logic [7:0]  arr_i [M],
    output logic        v_o
);
  logic sink;

  // x1  THE AXIS.  Whole-name gen-local struct VAR, six member forms.
  for (genvar i = 0; i < M; i++) begin : gen_x1
    p121::wide_t x1_t;
    assign x1_t = '{m_id:   sink,
                    m_hp:   two_i[i].m_hp,
                    m_idx:  arr_i[i],
                    m_lit:  8'hA5,
                    m_enum: p121::OpB,
                    m_nest: '{f0: 4'h1, f1: 4'h2}};
  end

  // x2  A SECOND whole-name gen-local struct VAR carrier in its own block.
  for (genvar i = 0; i < M; i++) begin : gen_x2
    p121::wide_t x2_t;
    assign x2_t = '{m_id:   sink,
                    m_hp:   two_i[i].m_hp,
                    m_idx:  arr_i[i],
                    m_lit:  8'hA5,
                    m_enum: p121::OpB,
                    m_nest: '{f0: 4'h1, f1: 4'h2}};
  end

  // x3  A SECOND generate depth: the target is declared in the INNER block.
  for (genvar i = 0; i < M; i++) begin : gen_x3o
    for (genvar j = 0; j < 2; j++) begin : gen_x3i
      p121::wide_t x3_t;
      assign x3_t = '{m_id:   sink,
                      m_hp:   two_i[i].m_hp,
                      m_idx:  arr_i[i],
                      m_lit:  8'hA5,
                      m_enum: p121::OpA,
                      m_nest: '{f0: 4'h3, f1: 4'h4}};
    end
  end

  // x4  The target is declared in the OUTER generate block and written from the
  //     INNER one — still gen-local for `bindVariable` (which skips gen scopes
  //     entirely), so the law reaches it.
  for (genvar i = 0; i < M; i++) begin : gen_x4o
    p121::wide_t x4_t;
    for (genvar j = 0; j < 1; j++) begin : gen_x4i
      assign x4_t = '{m_id:   sink,
                      m_hp:   two_i[i].m_hp,
                      m_idx:  arr_i[i],
                      m_lit:  8'h5A,
                      m_enum: p121::OpB,
                      m_nest: '{f0: 4'h5, f1: 4'h6}};
    end
  end

  // x5  A generate IF block rather than a for.
  if (M == 3) begin : gen_x5
    p121::wide_t x5_t;
    assign x5_t = '{m_id:   sink,
                    m_hp:   two_i[0].m_hp,
                    m_idx:  arr_i[0],
                    m_lit:  8'h00,
                    m_enum: p121::OpA,
                    m_nest: '{f0: 4'h7, f1: 4'h8}};
  end

  assign sink = d_i[0];
  assign v_o  = gen_x1[0].x1_t.m_id ^ gen_x2[0].x2_t.m_id ^
                gen_x3o[0].gen_x3i[0].x3_t.m_id ^ gen_x4o[0].x4_t.m_id ^
                gen_x5.x5_t.m_id;
endmodule
