// r10earl115 arm p3 -- THE MUST-STAY FLOOR and THE AWAY RISKS.
// MEASUREMENT ONLY.
//
// Every cell here is a shape where GOLDEN BINDS the non-first path elements,
// or where the two emitters already agree.  If this law fires on any of them
// the arm scores AWAY, and that is the whole point of the file.
//
//   x1  a MODULE-SCOPE keyed pattern         -- golden BINDS (t3 d0's twin)
//   x2  a gen-scope KEYED pattern whose TARGET is declared in the MODULE BODY
//                                            -- golden BINDS (r10earl114 t4 f2
//                                               = r10earl113's x2)
//   x3  a gen-scope POSITIONAL pattern       -- golden BINDS
//   x4  a gen-scope PLAIN cont_assign Rhs    -- golden BINDS
//   x5  a gen-scope BINARY-OPERATION operand -- golden BINDS
//   x6  a gen-scope ALWAYS_COMB pattern      -- golden leaves bare, and so do
//                                               we already (no move allowed)
//   x7  a gen-scope pattern with a SELECT Lhs (module-scope array element)
//                                            -- golden leaves bare
//   x8  a gen-scope pattern whose member value is a USER FUNCTION CALL
//       argument (r10earl112's user-call fence)
package p115f;
  typedef enum logic [2:0] { OpA = 3'h0, OpB = 3'h4 } op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_opcode;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module p3_fence115 #(parameter int M = 3) (
  input  logic        clk,
  input  p115f::h2d_t tl_h_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  p115f::h2d_t x1_mod;
  p115f::h2d_t x2_modtgt;
  p115f::h2d_t x7_arr [M];

  // x1  MODULE SCOPE -- golden binds BOTH elements here.
  assign x1_mod = '{ a_valid:  tl_h_i[0].a_valid,
                     a_opcode: tl_h_i[0].a_opcode,
                     a_data:   d_i };

  // x2  gen scope, MODULE-BODY target, WHOLE-NAME Lhs -- golden binds.
  if (M > 1) begin : gen_x2
    assign x2_modtgt = '{ a_valid:  tl_h_i[0].a_valid,
                          a_opcode: tl_h_i[0].a_opcode,
                          a_data:   d_i };
  end

  // x3  gen scope, POSITIONAL pattern -- golden binds.
  for (genvar i = 0; i < M; i++) begin : gen_x3
    p115f::h2d_t x3_t;
    assign x3_t = '{ tl_h_i[i].a_valid, tl_h_i[i].a_opcode, d_i };
  end

  // x4  gen scope, PLAIN Rhs (no pattern) -- golden binds.
  for (genvar i = 0; i < M; i++) begin : gen_x4
    logic x4_t;
    assign x4_t = tl_h_i[i].a_valid;
  end

  // x5  gen scope, BINARY-OPERATION operand -- golden binds.
  for (genvar i = 0; i < M; i++) begin : gen_x5
    logic x5_t;
    assign x5_t = tl_h_i[i].a_valid & clk;
  end

  // x6  gen scope, ALWAYS_COMB pattern -- bare on both sides already.
  for (genvar i = 0; i < M; i++) begin : gen_x6
    p115f::h2d_t x6_t;
    always_comb x6_t = '{ a_valid:  tl_h_i[i].a_valid,
                          a_opcode: tl_h_i[i].a_opcode,
                          a_data:   d_i };
  end

  // x7  gen scope, keyed pattern, SELECT Lhs into a module-scope array.
  for (genvar i = 0; i < M; i++) begin : gen_x7
    assign x7_arr[i] = '{ a_valid:  tl_h_i[i].a_valid,
                          a_opcode: tl_h_i[i].a_opcode,
                          a_data:   d_i };
  end

  // x8  gen scope, keyed pattern, member value is a USER CALL argument.
  function automatic logic pick8(input logic a);
    return a;
  endfunction
  for (genvar i = 0; i < M; i++) begin : gen_x8
    p115f::h2d_t x8_t;
    assign x8_t = '{ a_valid:  pick8(tl_h_i[i].a_valid),
                     a_opcode: tl_h_i[i].a_opcode,
                     a_data:   d_i };
  end

  assign v_o = x1_mod.a_valid;
endmodule
