// r10vearl115 single-cell adversarial arm -- MEASUREMENT ONLY.
// The package is r10earl115 arm p1's, verbatim in shape (the ENUM member is
// load-bearing: an all-`logic` packed struct port draws an unrelated
// `vpiNetType` head that stops the judge before it reaches a path element).
package pw5;
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

// THE FACE: r10earl115's `genAbove` fence with NO namesake anywhere.  ONE child
// module holding a gen-local pattern, instantiated at MODULE SCOPE (law fires)
// and INSIDE A GENERATE BLOCK (fenced).  r10vearl113's v4_ctx113 carries
// r10earl113's namesakes as well, so this is the fence on its own.
module w5_child #(parameter int M = 3) (
  input  pw5::h2d_t two_i [M],
  input  logic [7:0]  d_i,
  output logic        y_o
);
  for (genvar i = 0; i < M; i++) begin : gen_w5
    pw5::h2d_t w5_t;
    assign w5_t = '{ a_valid:  two_i[i].a_valid,
                     a_opcode: two_i[i].a_opcode,
                     a_data:   d_i };
  end
  assign y_o = gen_w5[0].w5_t.a_valid;
endmodule

module w5_nestinst #(parameter int M = 3) (
  input  logic        clk,
  input  pw5::h2d_t two_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  logic y_a;
  w5_child #(.M(M)) u_a (.two_i(two_i), .d_i(d_i), .y_o(y_a));
  for (genvar k = 0; k < 2; k++) begin : gen_inst
    logic y_g;
    w5_child #(.M(M)) u_c (.two_i(two_i), .d_i(d_i), .y_o(y_g));
  end
  assign v_o = y_a ^ gen_inst[0].y_g ^ gen_inst[1].y_g ^ clk;
endmodule
