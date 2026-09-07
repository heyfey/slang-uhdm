// r10earl116 arm q4_head116 — THE HEAD REPRODUCER.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The minimum that reproduces the Earlgrey_0_1/testflags head: a MODULE-SCOPE
// unpacked array of a PACKAGE packed struct, written from a for-generate scope
// through a SELECT Lhs with a KEYED assignment pattern whose members read a
// module-scope struct and a genvar-indexed vector — `tlul_socket_m1.sv:240-251`
// with the payload cut down to three members.
package q4p116;
  typedef struct packed {
    logic       d_valid;
    logic [2:0] d_opcode;
    logic [7:0] d_data;
  } d2h_t;
endpackage

module q4_sink116 (
    input q4p116::d2h_t p,
    output logic q
);
  assign q = p.d_valid;
endmodule

// the top is a WRAPPER, so the carrier module is a CHILD INSTANCE — the corpus
// shape (`u_xbar_main.u_sm1_17`), not a root module.
module q4_top116 (
    input  logic         clk,
    input  q4p116::d2h_t drsp_i,
    input  logic [2:0]   rspvalid_i,
    output logic         v_o
);
  q4_head116 u_sm (.clk(clk), .drsp_i(drsp_i), .rspvalid_i(rspvalid_i), .v_o(v_o));
endmodule

module q4_head116 #(
    parameter int M = 3
) (
    input  logic         clk,
    input  q4p116::d2h_t drsp_i,
    input  logic [M-1:0] rspvalid_i,
    output logic         v_o
);
  q4p116::d2h_t hrsp[M];
  logic [M-1:0] qw;

  for (genvar i = 0; i < M; i++) begin : gen_idrouting
    assign hrsp[i] = '{d_valid: rspvalid_i[i],
                       d_opcode: drsp_i.d_opcode,
                       d_data: drsp_i.d_data};
    // the array element is also a PORT ACTUAL, exactly as `tlul_socket_m1`'s
    // `hrsp_fifo_i[i]` feeds `.tl_d_i` — the shape that gives the Lhs a
    // `bit_select` over an unpacked array rather than a whole-name reference.
    q4_sink116 u_sink (.p(hrsp[i]), .q(qw[i]));
  end

  assign v_o = hrsp[0].d_valid ^ qw[0];
endmodule
