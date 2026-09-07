// r10v112 arm v4 -- THE SINGLE-INSTANCE TWIN of v3 (one instance, same child
// source), so "one vs three instances" is a controlled pair.  MEASUREMENT ONLY.
package pv4_112;
  typedef struct packed {
    logic       a_valid;
    logic [2:0] a_opcode;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module v4_child112 #(parameter int M = 2, parameter int OFF = 0) (
  input  pv4_112::h2d_t tl_h_i [4],
  output pv4_112::h2d_t o_o
);
  for (genvar i = 0; i < M; i++) begin : gen_c
    pv4_112::h2d_t s;
    assign s = '{ a_valid:  tl_h_i[i+OFF].a_valid,
                  a_opcode: tl_h_i[i].a_opcode,
                  a_data:   tl_h_i[i].a_data };
  end
  assign o_o = gen_c[0].s;
endmodule

module v4_one112 (
  input  pv4_112::h2d_t tl_h_i [4],
  output pv4_112::h2d_t a_o
);
  v4_child112 #(.M(3), .OFF(1)) u1 (.tl_h_i(tl_h_i), .o_o(a_o));
endmodule
