// r10earl90 g1 — THE HEAD MINIMISED, then the SAME read in many CONTEXTS.
// Earlgrey rv_timer.sv:82  .reg2hw_intr_enable_q_i (intr_timer_en[h*N_TIMERS+:N_TIMERS])
// with `localparam int N_TIMERS = 1;`.  The WIDTH operand is a BARE signed-int
// module localparam; golden stamps a bare signed int_typespec on the folded
// width constant, the pristine emitter mints it bare.
module sink90 #(parameter int W = 1) (input logic [W-1:0] a_i, output logic [W-1:0] b_o);
  assign b_o = a_i;
endmodule

function automatic logic [7:0] uf90(input logic [7:0] x);
  return x;
endfunction

module g1_head90;
  localparam int N_TIMERS = 1;   // the head's own declaration
  logic [15:0] sig, sig2, dst;
  logic [7:0]  wide;

  // (1) THE HEAD: gen-for, ELAB high_conn, genvar base, bare-localparam width.
  for (genvar h = 0; h < 2; h++) begin : gen_h
    sink90 #(.W(N_TIMERS)) u_hd (.a_i(sig[h*N_TIMERS +: N_TIMERS]), .b_o(dst[h +: 1]));
  end

  // (2) the same read with a LITERAL base inside the same gen-for.
  for (genvar j = 0; j < 2; j++) begin : gen_j
    sink90 #(.W(N_TIMERS)) u_lit (.a_i(sig[0 +: N_TIMERS]), .b_o());
  end

  // (3) an OUTPUT port's high_conn (the select is the actual of an output).
  for (genvar k = 0; k < 1; k++) begin : gen_k
    sink90 #(.W(N_TIMERS)) u_out (.a_i(sig2[k*N_TIMERS +: N_TIMERS]),
                                  .b_o(dst[k*N_TIMERS +: N_TIMERS]));
  end

  // (4) a USER-CALL argument wrapping the select, inside a gen-for conn.
  for (genvar m = 0; m < 1; m++) begin : gen_m
    sink90 #(.W(8)) u_call (.a_i(uf90({4'h0, sig[m*N_TIMERS +: N_TIMERS], 3'b0})), .b_o());
  end

  // (5) a SYSTEM-CALL argument wrapping the select.
  for (genvar n = 0; n < 1; n++) begin : gen_n
    sink90 #(.W(8)) u_sys (.a_i($unsigned({4'h0, sig[n*N_TIMERS +: N_TIMERS], 3'b0})), .b_o());
  end

  // (6) ONE OPERATION DEEP inside the high_conn.
  for (genvar p = 0; p < 1; p++) begin : gen_p
    sink90 #(.W(1)) u_op (.a_i(sig[p*N_TIMERS +: N_TIMERS] & sig2[p +: 1]), .b_o());
  end

  // (7) a module-body CONT_ASSIGN inside the same gen-for (no port at all).
  for (genvar q = 0; q < 1; q++) begin : gen_q
    logic [0:0] ca;
    assign ca = sig[q*N_TIMERS +: N_TIMERS];
  end

  // (8) a PROCEDURAL read and (9) a procedural LVALUE inside a gen-for.
  for (genvar r = 0; r < 1; r++) begin : gen_r
    logic [0:0] pv;
    always_comb pv = sig[r*N_TIMERS +: N_TIMERS];
    always_comb dst[r*N_TIMERS +: N_TIMERS] = sig2[r*N_TIMERS +: N_TIMERS];
  end

  // (10) a PLAIN (non-gen) instantiation's high_conn — the genvarConnFold arm
  //      is NOT armed here; the pristine emitter keeps a ref_obj width.
  sink90 #(.W(N_TIMERS)) u_flat (.a_i(sig[0 +: N_TIMERS]), .b_o());

  // (11) a DOTTED (hier_path) actual with the same width, in a gen-for.
  typedef struct packed { logic [15:0] f; } s90_t;
  s90_t st;
  for (genvar t = 0; t < 1; t++) begin : gen_t
    sink90 #(.W(N_TIMERS)) u_dot (.a_i(st.f[t*N_TIMERS +: N_TIMERS]), .b_o());
  end
endmodule
