// r10earl114 arm t2 -- THE CARRIER AXIS.  MEASUREMENT ONLY.
//
// Surelog's gate for the whole binding (Root_value AND the typespec edge) is
// `instance && (reduce == Reduce::Yes)` at
// CompileExpression.cpp:5457.  `reduce` is set to `Reduce::Yes` for a PACKAGE
// component and for ANY expression compiled with a non-null `instance`
// (CompileExpression.cpp:3688, inside `compileAssignmentPattern`) -- which is
// exactly the fact r10earl112 decoded for the genvar VALUE rendering: inside a
// pattern, and only there, an elaborated instance's index reduces.  This arm
// asks whether the TYPESPEC EDGE follows the same carrier split, one carrier at
// a time, with the SAME dotted path in every cell so the carrier is the only
// variable.
//
// The DEF view (`-parse` without `-elabuhdm`) is scored beside the ELAB one by
// the grid driver: `instance` is null in a definition compile, so the gate
// cannot hold there and the cells must be bare on both sides.
package p114c;
  typedef enum logic [2:0] { OpA = 3'h0, OpB = 3'h4 } op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_opcode;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module t2_carrier114 #(parameter int M = 3) (
  input  logic        clk,
  input  p114c::h2d_t tl_h_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o,
  output logic        w_o
);
  p114c::h2d_t c8_mod;
  logic        c9_mod;
  logic        c5_mod;

  // c1  KEYED pattern member value, gen-scope cont_assign -- THE HEAD.
  for (genvar i = 0; i < M; i++) begin : gen_c1
    p114c::h2d_t c1_t;
    assign c1_t = '{ a_valid:  tl_h_i[i].a_valid,
                     a_opcode: tl_h_i[i].a_opcode,
                     a_data:   d_i };
  end

  // c2  POSITIONAL pattern element, gen-scope cont_assign.
  for (genvar i = 0; i < M; i++) begin : gen_c2
    p114c::h2d_t c2_t;
    assign c2_t = '{ tl_h_i[i].a_valid, tl_h_i[i].a_opcode, d_i };
  end

  // c3  A pattern NESTED inside a pattern.
  for (genvar i = 0; i < M; i++) begin : gen_c3
    p114c::h2d_t c3_t [2];
    assign c3_t = '{ '{ a_valid:  tl_h_i[i].a_valid,
                        a_opcode: tl_h_i[i].a_opcode,
                        a_data:   d_i },
                     '{ a_valid:  1'b0,
                        a_opcode: p114c::OpA,
                        a_data:   d_i } };
  end

  // c4  A PLAIN cont_assign Rhs in a generate scope -- NO pattern at all.
  //     `compileAssignmentPattern`'s `Reduce::Yes` never runs here.
  for (genvar i = 0; i < M; i++) begin : gen_c4
    logic c4_t;
    assign c4_t = tl_h_i[i].a_valid;
  end

  // c5  A dotted path inside a BINARY OPERATION in a gen-scope cont_assign.
  for (genvar i = 0; i < M; i++) begin : gen_c5
    logic c5_t;
    assign c5_t = tl_h_i[i].a_valid & c5_mod;
  end

  // c6  A pattern in an ALWAYS_COMB inside a generate scope.
  for (genvar i = 0; i < M; i++) begin : gen_c6
    p114c::h2d_t c6_t;
    always_comb c6_t = '{ a_valid:  tl_h_i[i].a_valid,
                          a_opcode: tl_h_i[i].a_opcode,
                          a_data:   d_i };
  end

  // c7  A pattern in an INITIAL inside a generate scope.
  for (genvar i = 0; i < M; i++) begin : gen_c7
    p114c::h2d_t c7_t;
    initial c7_t = '{ a_valid:  tl_h_i[i].a_valid,
                      a_opcode: tl_h_i[i].a_opcode,
                      a_data:   d_i };
  end

  // c8  A MODULE-SCOPE cont_assign pattern -- the scope negative control.
  assign c8_mod = '{ a_valid:  tl_h_i[0].a_valid,
                     a_opcode: tl_h_i[0].a_opcode,
                     a_data:   d_i };

  // c9  A MODULE-SCOPE plain cont_assign Rhs.
  assign c9_mod = tl_h_i[1].a_valid;

  // c10 A pattern as a LOCALPARAM initializer (a param_assign carrier, a
  //     different producer entirely).
  localparam p114c::h2d_t C10_LP =
      '{ a_valid: 1'b1, a_opcode: p114c::OpB, a_data: 8'h7 };

  // c11 A pattern inside a FUNCTION -- `getObject`'s pexpr walk finds a
  //     task_func `io_decl`, which is a BaseClass and NOT an expr, a port or a
  //     param_assign, so NONE of the three branches runs.
  function automatic p114c::h2d_t mk11(input p114c::h2d_t a);
    return '{ a_valid: a.a_valid, a_opcode: a.a_opcode, a_data: d_i };
  endfunction
  for (genvar i = 0; i < M; i++) begin : gen_c11
    p114c::h2d_t c11_t;
    assign c11_t = mk11(tl_h_i[i]);
  end

  assign c5_mod = 1'b1;
  assign v_o = c8_mod.a_valid ^ c9_mod ^ C10_LP.a_valid;
  assign w_o = c5_mod;
endmodule
