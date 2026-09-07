// r10v112 arm v3 -- ONE vs THREE INSTANCES, and the PER-COPY VALUE.
// MEASUREMENT ONLY.
//
// The head's module is instantiated ONCE in the corpus, so the per-instance
// value axis is untested there.  Here the very same child carries the head
// shape and is instantiated THREE times with different parameters, and the
// per-unrolling value must differ per copy AND per instance.  A law that read
// a stale `currentScope` (RESUME section 9: `currentScope` is STALE throughout
// `emitInstance`) or a def-view parameter would collapse the three instances
// onto one value and this arm would show it.
package pv3_112;
  typedef struct packed {
    logic       a_valid;
    logic [2:0] a_opcode;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module v3_child112 #(parameter int M = 2, parameter int OFF = 0) (
  input  pv3_112::h2d_t tl_h_i [4],
  output pv3_112::h2d_t o_o
);
  for (genvar i = 0; i < M; i++) begin : gen_c
    pv3_112::h2d_t s;
    assign s = '{ a_valid:  tl_h_i[i+OFF].a_valid,
                  a_opcode: tl_h_i[i].a_opcode,
                  a_data:   tl_h_i[i].a_data };
  end
  assign o_o = gen_c[0].s;
endmodule

module v3_inst112 (
  input  pv3_112::h2d_t tl_h_i [4],
  output pv3_112::h2d_t a_o,
  output pv3_112::h2d_t b_o,
  output pv3_112::h2d_t c_o
);
  v3_child112 #(.M(2), .OFF(0)) u1 (.tl_h_i(tl_h_i), .o_o(a_o));
  v3_child112 #(.M(3), .OFF(1)) u2 (.tl_h_i(tl_h_i), .o_o(b_o));
  v3_child112 #(.M(4), .OFF(0)) u3 (.tl_h_i(tl_h_i), .o_o(c_o));
endmodule
