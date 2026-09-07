// r10vearl115 single-cell adversarial arm -- MEASUREMENT ONLY.
// The package is r10earl115 arm p1's, verbatim in shape (the ENUM member is
// load-bearing: an all-`logic` packed struct port draws an unrelated
// `vpiNetType` head that stops the judge before it reaches a path element).
package pw6;
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

// THE FACE: a gen scope inside an INTERFACE.  The consumer walk descends
// `interface_inst`; no arm of r10earl115's own grid puts a pattern there.
interface w6_if #(parameter int M = 3) (input logic clk);
  pw6::h2d_t two_i [M];
  logic [7:0]  d_i;
  for (genvar i = 0; i < M; i++) begin : gen_w6
    pw6::h2d_t w6_t;
    assign w6_t = '{ a_valid:  two_i[i].a_valid,
                     a_opcode: two_i[i].a_opcode,
                     a_data:   d_i };
  end
endinterface

module w6_iface #(parameter int M = 3) (
  input  logic clk,
  output logic v_o
);
  w6_if #(.M(M)) u_if (.clk(clk));
  assign v_o = u_if.gen_w6[0].w6_t.a_valid ^ clk;
endmodule
