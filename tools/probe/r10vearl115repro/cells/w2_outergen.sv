// r10vearl115 single-cell adversarial arm -- MEASUREMENT ONLY.
// The package is r10earl115 arm p1's, verbatim in shape (the ENUM member is
// load-bearing: an all-`logic` packed struct port draws an unrelated
// `vpiNetType` head that stops the judge before it reaches a path element).
package pw2;
  typedef enum logic [2:0] { OpA = 3'h0, OpB = 3'h4 } op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_opcode;
    logic [7:0] a_data;
  } h2d_t;
  typedef struct packed {
    h2d_t       lo;
    logic [3:0] hi;
  } two_t;
endpackage

// THE FACE: a WHOLE-NAME Lhs whose target is declared in the ENCLOSING generate
// block, assigned from an INNER one.  `lhsGenLocal115` is true so the law fires;
// nothing in r10earl115's grid holds a target that is gen-local but not local to
// the assigning gen scope.
module w2_outergen #(parameter int M = 3) (
  input  logic        clk,
  input  pw2::h2d_t two_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  for (genvar i = 0; i < M; i++) begin : gen_w2
    pw2::h2d_t w2_t;
    if (i >= 0) begin : inner
      assign w2_t = '{ a_valid:  two_i[i].a_valid,
                       a_opcode: two_i[i].a_opcode,
                       a_data:   d_i };
    end
  end
  assign v_o = gen_w2[0].w2_t.a_valid ^ clk;
endmodule
