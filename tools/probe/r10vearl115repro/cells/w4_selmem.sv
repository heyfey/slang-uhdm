// r10vearl115 single-cell adversarial arm -- MEASUREMENT ONLY.
// The package is r10earl115 arm p1's, verbatim in shape (the ENUM member is
// load-bearing: an all-`logic` packed struct port draws an unrelated
// `vpiNetType` head that stops the judge before it reaches a path element).
package pw4;
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

// THE FACE: a MemberAccess OF an ELEMENT SELECT (`arr[i].lo`) into a
// MODULE-SCOPE array -- two select levels on the Lhs, recorded by the law.
module w4_selmem #(parameter int M = 3) (
  input  logic        clk,
  input  pw4::h2d_t two_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  pw4::two_t w4_arr [M];
  for (genvar i = 0; i < M; i++) begin : gen_w4
    assign w4_arr[i].lo = '{ a_valid:  two_i[i].a_valid,
                             a_opcode: two_i[i].a_opcode,
                             a_data:   d_i };
  end
  assign v_o = w4_arr[0].lo.a_valid ^ clk;
endmodule
