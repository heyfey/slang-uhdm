// r10vearl115 single-cell adversarial arm -- MEASUREMENT ONLY.
// The package is r10earl115 arm p1's, verbatim in shape (the ENUM member is
// load-bearing: an all-`logic` packed struct port draws an unrelated
// `vpiNetType` head that stops the judge before it reaches a path element).
package pw1;
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

// THE FACE: a MemberAccess Lhs whose target is declared in the MODULE BODY.
// r10earl115 records it (the gate only exempts a WHOLE-NAME module-scope Lhs),
// so if golden BINDS here the patch is a regression.  p3_fence115's x7 is the
// bit-select twin; this is the member twin, untested there.
module w1_memlhs #(parameter int M = 3) (
  input  logic        clk,
  input  pw1::h2d_t two_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  pw1::two_t w1_mod;
  if (M > 1) begin : gen_w1
    assign w1_mod.lo = '{ a_valid:  two_i[0].a_valid,
                          a_opcode: two_i[0].a_opcode,
                          a_data:   d_i };
  end
  assign v_o = w1_mod.lo.a_valid ^ clk;
endmodule
