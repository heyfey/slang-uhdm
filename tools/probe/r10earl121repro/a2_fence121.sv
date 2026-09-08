// r10earl121 arm a2_fence121 — THE FENCE of § `genCaPatKeepTagDefView121`.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// NOTHING IN THIS FILE MAY MOVE, in either view.  Every cell is a keyed
// assignment pattern that the law must NOT reach, one per reason:
//
//   y1  a GEN-SCOPE continuous assign whose target is declared in the MODULE
//       BODY.  `bindVariable` (CompileStmt.cpp:3089-3148) recurses PAST a
//       `gen_scope`, finds it, `UhdmWriter::writeCont_assign`'s `tps` is filled
//       and its OWN flatten runs — in EVERY mode.  This is the AWAY risk and it
//       is the committed `genCaLhsGenLocal113` fence; golden is FLAT here in
//       both views.
//   y2  a gen-local target whose NAME is ALSO declared in the module body.
//       `bindVariable` binds BY NAME, so the namesake is found and golden
//       flattens (r10vearl113's arm `v1_decl113` cell a3).  Golden FLAT, both
//       views.
//   y3  a SELECT Lhs on a MODULE-scope unpacked array — the corpus's own
//       `hrsp_fifo_i[i]` shape.  `cont_assign::DeepClone`'s second test wants
//       `Actual_group<struct_var>` and a `bit_select` answers the ARRAY, and
//       `bindVariable` is handed the array name, not the element.  Golden
//       TAGGED in both views and OURS ALREADY MATCHES.
//   y4  a SELECT Lhs on a GEN-LOCAL unpacked array.
//   y5  a MEMBER (`hier_path`) Lhs — not a `ref_obj` at all.
//   y6  a POSITIONAL pattern with a gen-local whole-name target.  There are no
//       keys, so `compileAssignmentPattern` mints no `tagged_pattern` and there
//       is nothing to keep; the emitter's own gate requires
//       `StructuredAssignmentPattern`.
//   y7  a MODULE-SCOPE continuous assign with a whole-name struct target — not
//       in a generate scope at all; the writer flattens it in every mode.
//   y8  a keyed pattern in an `always_comb` inside a generate scope — not a
//       continuous assign; neither flatten is a procedural one.
//   y9  a keyed pattern as a PARAMETER initializer inside a generate scope.
//   y10 a REPLICATED pattern (`'{2{...}}`, `vpiMultiAssignmentPatternOp`).
package q121;
  typedef struct packed {
    logic       a_v;
    logic [7:0] a_d;
  } h2d_t;
  typedef struct packed {
    logic v;
    h2d_t lo;
  } outer_t;
endpackage

module a2_fence121 #(
    parameter int M = 3
) (
    input  logic       clk,
    input  q121::h2d_t two_i [M],
    input  logic [7:0] d_i,
    output logic       v_o
);
  q121::h2d_t marr [M];      // y3 target
  q121::h2d_t mvar;          // y1 target
  q121::h2d_t name_t;        // y2 namesake (also declared gen-locally)
  q121::h2d_t mtop;          // y7 target
  q121::h2d_t pos_t;         // y6 sibling reader

  // y1  MODULE-scope target written from a generate scope: golden FLAT, both
  //     views.  THE FENCE.
  if (M == 3) begin : gen_y1
    assign mvar = '{a_v: two_i[0].a_v, a_d: d_i};
  end

  // y2  gen-local target whose NAME is also a module-body declaration.
  for (genvar i = 0; i < M; i++) begin : gen_y2
    q121::h2d_t name_t;
    assign name_t = '{a_v: two_i[i].a_v, a_d: d_i};
  end

  // y3  SELECT Lhs on a module-scope unpacked array (the corpus shape).
  for (genvar i = 0; i < M; i++) begin : gen_y3
    assign marr[i] = '{a_v: two_i[i].a_v, a_d: d_i};
  end

  // y4  SELECT Lhs on a gen-local unpacked array.
  for (genvar i = 0; i < M; i++) begin : gen_y4
    q121::h2d_t garr [2];
    assign garr[0] = '{a_v: two_i[i].a_v, a_d: d_i};
  end

  // y5  MEMBER (hier_path) Lhs.
  for (genvar i = 0; i < M; i++) begin : gen_y5
    q121::outer_t y5_t;
    assign y5_t.lo = '{a_v: two_i[i].a_v, a_d: d_i};
  end

  // y6  POSITIONAL pattern, gen-local whole-name target: no keys, no tags.
  for (genvar i = 0; i < M; i++) begin : gen_y6
    q121::h2d_t y6_t;
    assign y6_t = '{two_i[i].a_v, d_i};
  end

  // y7  MODULE-SCOPE continuous assign, whole-name struct target.
  assign mtop = '{a_v: two_i[0].a_v, a_d: d_i};

  // y8  a keyed pattern in an always_comb inside a generate scope.
  for (genvar i = 0; i < M; i++) begin : gen_y8
    q121::h2d_t y8_t;
    always_comb y8_t = '{a_v: two_i[i].a_v, a_d: d_i};
  end

  // y9  a keyed pattern as a gen-scope PARAMETER initializer.
  for (genvar i = 0; i < M; i++) begin : gen_y9
    localparam q121::h2d_t Y9 = '{a_v: 1'b1, a_d: 8'h11};
    wire [7:0] y9_w = Y9.a_d;
  end

  // y10 a REPLICATED pattern.
  for (genvar i = 0; i < M; i++) begin : gen_y10
    logic [1:0][7:0] y10_t;
    assign y10_t = '{2{d_i}};
  end

  assign pos_t = '{1'b0, 8'h00};
  assign v_o = mvar.a_v ^ marr[0].a_v ^ mtop.a_v ^ pos_t.a_v ^
               gen_y2[0].name_t.a_v ^ gen_y5[0].y5_t.v ^ gen_y6[0].y6_t.a_v ^
               gen_y8[0].y8_t.a_v ^ gen_y9[0].y9_w[0] ^ gen_y10[0].y10_t[0][0] ^
               gen_y4[0].garr[0].a_v ^ name_t.a_v;
endmodule
