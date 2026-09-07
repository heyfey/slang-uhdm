// r10vearl115 single-cell adversarial arm -- MEASUREMENT ONLY.
package pw13;
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

// THE FACE: a hier_path inside a CONCATENATION operand of the pattern (not a
// direct operand of the pattern operation).
module w13_concat #(parameter int M = 3) (
  input  logic        clk,
  input  pw13::h2d_t two_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  for (genvar i = 0; i < M; i++) begin : gen_w13
    pw13::h2d_t w13_t;
    assign w13_t = '{ a_valid:  two_i[i].a_valid,
                      a_opcode: two_i[i].a_opcode,
                      a_data:   { 5'h3, two_i[i].a_opcode } };
  end
  assign v_o = gen_w13[0].w13_t.a_valid ^ clk;
endmodule
