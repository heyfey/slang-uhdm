// r10earl117 arm p4_head117 — THE HEAD REPRODUCER.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// `tlul_socket_m1.sv:233-252` cut to three members: a for-generate whose
// continuous assign writes an unpacked array element through a SELECT Lhs with
// a KEYED assignment pattern, two of whose member values are BARE BIT-SELECTS
// on MODULE-SCOPE PACKED VECTORS indexed by the genvar (`hfifo_rspvalid[i]` at
// :241 and `hgrant[i]` at :250 — the head and the object one ladder step
// behind it), and one of which is a dotted member read of a module-scope
// struct (the sibling class that already agrees).
//
// The top is a WRAPPER so the carrier module is a CHILD INSTANCE, the corpus
// shape (`u_xbar_main.u_sm1_17`), not a root module.
package p4p117;
  typedef struct packed {
    logic       d_valid;
    logic [2:0] d_opcode;
    logic       a_ready;
  } d2h_t;
endpackage

module p4_sink117 (
    input p4p117::d2h_t p,
    output logic q
);
  assign q = p.d_valid;
endmodule

module p4_top117 (
    input  logic         clk,
    input  p4p117::d2h_t drsp_i,
    input  logic [2:0]   rsp_i,
    output logic         v_o
);
  p4_head117 u_sm1_17 (.clk(clk), .drsp_i(drsp_i), .rsp_i(rsp_i), .v_o(v_o));
endmodule

module p4_head117 #(
    parameter int M = 3
) (
    input  logic         clk,
    input  p4p117::d2h_t drsp_i,
    input  logic [M-1:0] rsp_i,
    output logic         v_o
);
  p4p117::d2h_t     hrsp_fifo_i [M];
  logic [M-1:0]     hfifo_rspvalid;   // the head's base object
  logic [M-1:0]     hgrant;           // the ladder's second object
  logic [M-1:0]     qw;

  assign hfifo_rspvalid = rsp_i;
  assign hgrant         = ~rsp_i;

  for (genvar i = 0; i < M; i++) begin : gen_idrouting
    assign hrsp_fifo_i[i] = '{
      d_valid:  hfifo_rspvalid[i],    // :241 — THE HEAD
      d_opcode: drsp_i.d_opcode,      // the sibling class that already agrees
      a_ready:  hgrant[i]             // :250 — one ladder step behind
    };
    // the array element also feeds an instance port, exactly as the corpus's
    // `hrsp_fifo_i[i]` feeds `.tl_d_i` — the shape that gives the Lhs a
    // bit_select over an unpacked array rather than a whole-name reference.
    p4_sink117 u_sink (.p(hrsp_fifo_i[i]), .q(qw[i]));
  end

  assign v_o = hrsp_fifo_i[0].d_valid ^ qw[0];
endmodule
