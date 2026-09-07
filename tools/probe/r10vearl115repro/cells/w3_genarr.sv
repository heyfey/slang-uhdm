// r10vearl115 single-cell adversarial arm -- MEASUREMENT ONLY.
// The package is r10earl115 arm p1's, verbatim in shape (the ENUM member is
// load-bearing: an all-`logic` packed struct port draws an unrelated
// `vpiNetType` head that stops the judge before it reaches a path element).
package pw3;
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

// THE FACE: a BIT-SELECT Lhs into a GEN-LOCAL array (p3's x7 selects into a
// MODULE-SCOPE array).
module w3_genarr #(parameter int M = 3) (
  input  logic        clk,
  input  pw3::h2d_t two_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  for (genvar i = 0; i < M; i++) begin : gen_w3
    pw3::h2d_t w3_arr [2];
    assign w3_arr[0] = '{ a_valid:  two_i[i].a_valid,
                          a_opcode: two_i[i].a_opcode,
                          a_data:   d_i };
    assign w3_arr[1] = '{ a_valid:  two_i[i].a_valid,
                          a_opcode: two_i[i].a_opcode,
                          a_data:   d_i };
  end
  assign v_o = gen_w3[0].w3_arr[0].a_valid ^ clk;
endmodule
