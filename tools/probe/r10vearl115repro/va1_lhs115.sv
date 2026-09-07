// r10vearl115 ADVERSARIAL ARM va1 -- THE Lhs SHAPE AXIS.  MEASUREMENT ONLY.
//
// r10earl115's record site gates on the Lhs:
//     record unless (whole-name reference AND target NOT gen-local)
// so every NON-whole-name Lhs is recorded whatever its target's scope, and
// every gen-local target is recorded whatever the Lhs shape.  p3_fence115
// tests exactly ONE non-whole-name shape (x7, a bit_select into a module-scope
// array).  These cells are the ones it does not reach.
//
//   a1  MemberAccess Lhs into a MODULE-SCOPE struct-of-struct   -- RECORDED
//   a2  MemberAccess Lhs into a GEN-LOCAL struct-of-struct      -- RECORDED
//   a3  whole-name Lhs whose target is declared in an OUTER GEN BLOCK
//                                                               -- RECORDED
//   a4  bit-select Lhs into a GEN-LOCAL array                   -- RECORDED
//   a5  MemberAccess of an ELEMENT SELECT of a module-scope array -- RECORDED
//   a6  whole-name gen-local, no namesake  -- the POSITIVE CONTROL (the law
//       must fire, golden must be bare)
package v115a;
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
endpackage

module va1_lhs115 #(parameter int M = 3) (
  input  logic       clk,
  input  v115a::h2d_t tl_h_i [M],
  input  logic [7:0] d_i,
  output logic       v_o
);
  v115a::two_t a1_modnest;
  v115a::two_t a5_arr [M];

  // a1 -- MemberAccess Lhs, target declared in the MODULE BODY.
  if (M > 1) begin : gen_a1
    assign a1_modnest.lo = '{ a_valid: tl_h_i[0].a_valid,
                              a_op:    tl_h_i[0].a_op,
                              a_data:  d_i };
  end

  // a2 -- MemberAccess Lhs, target declared IN the generate block.
  for (genvar i = 0; i < M; i++) begin : gen_a2
    v115a::two_t a2_t;
    assign a2_t.lo = '{ a_valid: tl_h_i[i].a_valid,
                        a_op:    tl_h_i[i].a_op,
                        a_data:  d_i };
  end

  // a3 -- whole-name Lhs, target declared in the ENCLOSING generate block,
  //       assigned from an INNER one.  gen-local, so recorded.
  for (genvar i = 0; i < M; i++) begin : gen_a3
    v115a::h2d_t a3_t;
    if (i >= 0) begin : inner
      assign a3_t = '{ a_valid: tl_h_i[i].a_valid,
                       a_op:    tl_h_i[i].a_op,
                       a_data:  d_i };
    end
  end

  // a4 -- bit-select Lhs into a GEN-LOCAL array.
  for (genvar i = 0; i < M; i++) begin : gen_a4
    v115a::h2d_t a4_arr [2];
    assign a4_arr[0] = '{ a_valid: tl_h_i[i].a_valid,
                          a_op:    tl_h_i[i].a_op,
                          a_data:  d_i };
    assign a4_arr[1] = '{ a_valid: tl_h_i[i].a_valid,
                          a_op:    tl_h_i[i].a_op,
                          a_data:  d_i };
  end

  // a5 -- MemberAccess of an ELEMENT SELECT, module-scope array.
  for (genvar i = 0; i < M; i++) begin : gen_a5
    assign a5_arr[i].lo = '{ a_valid: tl_h_i[i].a_valid,
                             a_op:    tl_h_i[i].a_op,
                             a_data:  d_i };
  end

  // a6 -- POSITIVE CONTROL: the shape the law is written for.
  for (genvar i = 0; i < M; i++) begin : gen_a6
    v115a::h2d_t a6_t;
    assign a6_t = '{ a_valid: tl_h_i[i].a_valid,
                     a_op:    tl_h_i[i].a_op,
                     a_data:  d_i };
  end

  assign v_o = a1_modnest.lo.a_valid;
endmodule
