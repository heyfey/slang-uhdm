// r10earl116 arm q3_mix116 — THE OPERAND-MIX AXIS.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// `ExprEval::flattenPatternAssignments` (~/git-repos/UHDM/templates/
// ExprEval.cpp:824-874) walks the operand list and BAILS OUTRIGHT at the first
// operand that is neither a `tagged_pattern` nor a plain value:
//
//     } else if (oper->UhdmType() == uhdmoperation) { return result;
//     } else if (oper->UhdmType() == uhdmconstant)  { return result; }
//
// The pass brief framed the corpus head as that bail firing.  It does not: at
// `tlul_socket_m1.sv:241` all ten operands ARE tagged_patterns and the function
// is never called at all (the Lhs gate in `cont_assign::DeepClone` refuses it).
// This arm gives the bail its OWN cells, so the claim is measured rather than
// argued, and covers the three POSITIONS the brief names.
//
//   e1 whole-name Lhs, POSITIONAL pattern, every operand a plain ref
//   e2 whole-name Lhs, POSITIONAL pattern, FIRST operand a constant
//   e3 whole-name Lhs, POSITIONAL pattern, MIDDLE operand a constant
//   e4 whole-name Lhs, POSITIONAL pattern, LAST operand a constant
//   e5 whole-name Lhs, POSITIONAL pattern, MIDDLE operand an OPERATION
//   e6 whole-name Lhs, KEYED pattern with a `default:` key
//   e7 whole-name Lhs, KEYED pattern whose member value is a NESTED pattern
//   e8 SELECT Lhs, POSITIONAL pattern, every operand a plain ref
//   e9 SELECT Lhs, KEYED pattern with a `default:` key
package q3p116;
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
  typedef struct packed {
    logic       d_valid;
    logic [1:0] d_opcode;
    logic [7:0] d_data;
  } d2h_t;
endpackage

module q3_mix116 #(
    parameter int M = 3
) (
    input  logic         clk,
    input  q3p116::h2d_t two_i[M],
    input  q3p116::op_e  op_i,
    input  logic [7:0]   d_i,
    input  logic         v_i,
    output logic         v_o
);
  q3p116::h2d_t   e8a[M];
  q3p116::d2h_t   e9a[M];

  for (genvar i = 0; i < M; i++) begin : gen_e1
    q3p116::h2d_t t;
    assign t = '{two_i[i].a_valid, op_i, d_i};
  end

  for (genvar i = 0; i < M; i++) begin : gen_e2
    q3p116::h2d_t t;
    assign t = '{1'b1, op_i, d_i};
  end

  for (genvar i = 0; i < M; i++) begin : gen_e3
    q3p116::h2d_t t;
    assign t = '{two_i[i].a_valid, q3p116::OpA, d_i};
  end

  for (genvar i = 0; i < M; i++) begin : gen_e4
    q3p116::h2d_t t;
    assign t = '{two_i[i].a_valid, op_i, 8'h5a};
  end

  for (genvar i = 0; i < M; i++) begin : gen_e5
    q3p116::h2d_t t;
    assign t = '{two_i[i].a_valid, op_i, d_i ^ 8'h0f};
  end

  for (genvar i = 0; i < M; i++) begin : gen_e6
    q3p116::d2h_t t;
    assign t = '{d_valid: two_i[i].a_valid, default: '0};
  end

  for (genvar i = 0; i < M; i++) begin : gen_e7
    q3p116::outer_t t;
    assign t = '{v: two_i[i].a_valid, lo: '{f0: d_i[3:0], f1: d_i[7:4]}};
  end

  for (genvar i = 0; i < M; i++) begin : gen_e8
    assign e8a[i] = '{two_i[i].a_valid, op_i, d_i};
  end

  for (genvar i = 0; i < M; i++) begin : gen_e9
    assign e9a[i] = '{d_valid: two_i[i].a_valid, default: '0};
  end

  assign v_o = gen_e1[0].t.a_valid ^ gen_e2[0].t.a_valid ^ gen_e3[0].t.a_valid ^
               gen_e4[0].t.a_valid ^ gen_e5[0].t.a_valid ^ gen_e6[0].t.d_valid ^
               gen_e7[0].t.v ^ e8a[0].a_valid ^ e9a[0].d_valid ^ v_i;
endmodule
