// r10earl116 arm q2_car116 — THE CARRIER AXIS and THE DEPTH AXIS.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// q1 varies the Lhs and holds the carrier fixed; this arm holds the Lhs SHAPE
// fixed (a SELECT — the shape golden never flattens) and varies the CARRIER,
// so the SITE fence of § patCaFlatLhsWholeName116 is measured rather than
// asserted.  Only `d5`/`d6`/`d7` are inside the site the law narrows (the
// ELABORATED generate-scope continuous assign of `emitBlock`); every other cell
// is a carrier the site cannot reach and must therefore be UNCHANGED.
//
//   d1 MODULE-SCOPE continuous assign, select Lhs, keyed pattern
//   d2 gen-scope, select Lhs, POSITIONAL pattern (not StructuredAssignmentPattern)
//   d3 gen-scope, select Lhs, `always_comb`
//   d4 gen-scope, select Lhs, `initial`
//   d5 gen-scope at DEPTH 2, select Lhs, keyed pattern
//   d6 generate-IF scope, select Lhs, keyed pattern
//   d7 gen-scope, select Lhs, keyed pattern, target GEN-LOCAL at depth 2
//   d8 gen-scope, select Lhs, PLAIN (non-pattern) Rhs
package q2p116;
  typedef enum logic [2:0] {OpA = 3'h0, OpB = 3'h4} op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_opcode;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module q2_car116 #(
    parameter int M = 3
) (
    input  logic        clk,
    input  q2p116::h2d_t two_i[M],
    input  logic [7:0]  d_i,
    output logic        v_o
);
  q2p116::h2d_t a1[M];
  q2p116::h2d_t a2[M];
  q2p116::h2d_t a3[M];
  q2p116::h2d_t a4[M];
  q2p116::h2d_t a5[M];
  q2p116::h2d_t a6[M];
  q2p116::h2d_t a8[M];
  q2p116::h2d_t plain;

  // d1  MODULE SCOPE.
  assign a1[0] = '{a_valid: two_i[0].a_valid, a_opcode: q2p116::OpA, a_data: d_i};

  // d2  gen scope, POSITIONAL pattern.
  for (genvar i = 0; i < M; i++) begin : gen_d2
    assign a2[i] = '{two_i[i].a_valid, q2p116::OpA, d_i};
  end

  // d3  gen scope, always_comb.
  for (genvar i = 0; i < M; i++) begin : gen_d3
    always_comb a3[i] = '{a_valid: two_i[i].a_valid, a_opcode: q2p116::OpA, a_data: d_i};
  end

  // d4  gen scope, initial.
  for (genvar i = 0; i < M; i++) begin : gen_d4
    initial a4[i] = '{a_valid: 1'b0, a_opcode: q2p116::OpA, a_data: 8'h0};
  end

  // d5  DEPTH 2.
  for (genvar i = 0; i < M; i++) begin : gen_d5o
    for (genvar j = 0; j < 1; j++) begin : gen_d5i
      assign a5[i] = '{a_valid: two_i[i].a_valid, a_opcode: q2p116::OpA, a_data: d_i};
    end
  end

  // d6  generate-IF scope.
  if (M == 3) begin : gen_d6
    assign a6[1] = '{a_valid: two_i[1].a_valid, a_opcode: q2p116::OpA, a_data: d_i};
  end

  // d7  GEN-LOCAL array target at depth 2.
  for (genvar i = 0; i < M; i++) begin : gen_d7o
    q2p116::h2d_t g7[2];
    for (genvar j = 0; j < 1; j++) begin : gen_d7i
      assign g7[0] = '{a_valid: two_i[i].a_valid, a_opcode: q2p116::OpA, a_data: d_i};
    end
  end

  // d8  gen scope, PLAIN Rhs (no pattern at all).
  for (genvar i = 0; i < M; i++) begin : gen_d8
    assign a8[i] = two_i[i];
  end

  assign plain = a1[0];
  assign v_o = plain.a_valid ^ a2[0].a_valid ^ a3[0].a_valid ^ a4[0].a_valid ^
               a5[0].a_valid ^ a6[1].a_valid ^ a8[0].a_valid ^
               gen_d7o[0].g7[0].a_valid;
endmodule
