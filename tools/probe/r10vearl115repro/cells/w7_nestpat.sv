// r10vearl115 single-cell adversarial arm -- MEASUREMENT ONLY.
// The package is r10earl115 arm p1's, verbatim in shape (the ENUM member is
// load-bearing: an all-`logic` packed struct port draws an unrelated
// `vpiNetType` head that stops the judge before it reaches a path element).
package pw7;
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

// THE FACE: a NESTED assignment pattern.  The consumer clears elements only on
// hier_paths that are DIRECT operands of the outer pattern, so an inner
// pattern's paths are out of reach -- a residue if golden is bare there, a
// fence if golden binds.
module w7_nestpat #(parameter int M = 3) (
  input  logic        clk,
  input  pw7::h2d_t two_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  for (genvar i = 0; i < M; i++) begin : gen_w7
    pw7::two_t w7_t;
    assign w7_t = '{ lo: '{ a_valid:  two_i[i].a_valid,
                            a_opcode: two_i[i].a_opcode,
                            a_data:   d_i },
                     hi: 4'h3 };
  end
  assign v_o = gen_w7[0].w7_t.lo.a_valid ^ clk;
endmodule
