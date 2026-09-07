// r10vearl115 ADVERSARIAL ARM va3 -- THE Rhs SHAPE AXIS.  MEASUREMENT ONLY.
//
// r10earl115's consumer clears `Path_elems[1..]` on EVERY `hier_path` that is a
// DIRECT operand of the pattern operation, whatever that path points at.  These
// cells vary what the operands are, not what the Lhs is.
//
//   c1  a NESTED pattern (an inner assignment-pattern operand carrying a
//       hier_path) -- the walk does not descend, so this measures whether it
//       SHOULD (a residue) or must not (a fence)
//   c2  MIXED operands: a path rooted at a module-scope ARRAY of two-component
//       paths and a path rooted at an array of THREE-component ones
//   c3  a `default:` key beside a hier_path member value
//   c4  a hier_path inside a CONCATENATION operand
//   c5  the SAME path used twice, once directly and once inside a concat
//   c6  a path rooted at an INTERFACE ARRAY port
//
// (An undotted MODULE-BODY struct read from a generate scope is NOT here: it
// draws Surelog's [ERR:UH0725] Unresolved hierarchical reference, and an arm
// whose golden is an error message tests nothing -- r10earl115's p2 cut two
// cells for the same reason.)
package v115r;
  typedef enum logic [2:0] { OpA = 3'h0, OpB = 3'h4 } op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_op;
    logic [7:0] a_data;
  } h2d_t;
  typedef struct packed {
    h2d_t       lo;
    logic [3:0] hi;
  } two_t;
  typedef struct packed {
    logic       b_valid;
    logic [7:0] b_data;
  } plain_t;
endpackage

interface vr_if115 (input logic clk);
  logic       s_valid;
  v115r::op_e s_op;
endinterface

module va3_rhs115 #(parameter int M = 3) (
  input  logic        clk,
  input  v115r::h2d_t tl_h_i  [M],
  input  v115r::two_t three_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  vr_if115 u_ifa [M] (.clk(clk));

  // c1 -- a NESTED pattern operand.
  for (genvar i = 0; i < M; i++) begin : gen_c1
    v115r::two_t c1_t;
    assign c1_t = '{ lo: '{ a_valid: tl_h_i[i].a_valid,
                            a_op:    tl_h_i[i].a_op,
                            a_data:  d_i },
                     hi: 4'h3 };
  end

  // c2 -- MIXED path lengths in one pattern.
  for (genvar i = 0; i < M; i++) begin : gen_c2
    v115r::h2d_t c2_t;
    assign c2_t = '{ a_valid: tl_h_i[i].a_valid,
                     a_op:    three_i[i].lo.a_op,
                     a_data:  8'h5a };
  end

  // c3 -- a `default:` key beside a hier_path member value.
  for (genvar i = 0; i < M; i++) begin : gen_c3
    v115r::plain_t c3_t;
    assign c3_t = '{ b_valid: tl_h_i[i].a_valid,
                     default: '0 };
  end

  // c4 -- a hier_path inside a CONCATENATION operand.
  for (genvar i = 0; i < M; i++) begin : gen_c4
    v115r::h2d_t c4_t;
    assign c4_t = '{ a_valid: tl_h_i[i].a_valid,
                     a_op:    tl_h_i[i].a_op,
                     a_data:  { 5'h3, tl_h_i[i].a_op } };
  end

  // c5 -- the SAME path twice, once direct and once inside a concat.
  for (genvar i = 0; i < M; i++) begin : gen_c5
    v115r::two_t c5_t;
    assign c5_t = '{ lo: '{ a_valid: tl_h_i[i].a_valid,
                            a_op:    v115r::OpB,
                            a_data:  8'h0 },
                     hi: { 1'b0, tl_h_i[i].a_op } };
  end

  // c6 -- a path rooted at an INTERFACE ARRAY port.
  for (genvar i = 0; i < M; i++) begin : gen_c6
    v115r::h2d_t c6_t;
    assign c6_t = '{ a_valid: u_ifa[i].s_valid,
                     a_op:    u_ifa[i].s_op,
                     a_data:  d_i };
  end

  assign v_o = gen_c1[0].c1_t.lo.a_valid ^ gen_c2[0].c2_t.a_valid ^
               gen_c3[0].c3_t.b_valid ^ gen_c4[0].c4_t.a_valid ^
               gen_c5[0].c5_t.lo.a_valid ^ gen_c6[0].c6_t.a_valid;
endmodule
