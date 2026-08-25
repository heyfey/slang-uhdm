// r10earl91 g1 — THE HEAD MINIMISED, then ELEVEN PARENTS for ONE dotted read.
// rv_timer.sv:56  `assign prescaler = '{reg2hw.cfg0.prescale.q};`
// prescaler is `logic [11:0] prescaler [N_HARTS]` — an UNPACKED ARRAY of ONE
// 12-bit element — and the pattern's only member is a 4-element hier_path.
package p91;
  typedef struct packed {
    logic [11:0] q;
  } presc_t;
  typedef struct packed {
    logic [7:0] q;
  } stp_t;
  typedef struct packed {
    presc_t prescale;
    stp_t   step;
  } cfg_t;
  typedef struct packed {
    cfg_t cfg0;
    logic ctrl;
  } r2h_t;
endpackage

module snk91 (input logic [11:0] a_i, output logic [11:0] z_o);
  assign z_o = a_i;
endmodule

module top91 (input logic clk, input logic [11:0] din,
              output logic [11:0] o1, output logic [7:0] o2,
              output logic [23:0] o3, output logic [11:0] o4,
              output logic [11:0] o5, output logic [11:0] o6,
              output logic [11:0] o7, output logic o8,
              output logic [11:0] o9, output logic [11:0] oa,
              output logic [11:0] ob);
  import p91::*;
  localparam int NH = 1;

  r2h_t reg2hw;

  // ---- the head itself ------------------------------------------------
  logic [11:0] prescaler [NH];
  assign prescaler = '{reg2hw.cfg0.prescale.q};        // H1: pattern elem 0
  assign o1 = prescaler[0];

  // ---- the SAME dotted read under TEN OTHER PARENTS --------------------
  // P2 a cont_assign RHS with NO pattern
  assign o4 = reg2hw.cfg0.prescale.q;
  // P3 a concatenation
  assign o3 = {reg2hw.cfg0.prescale.q, reg2hw.cfg0.step.q, 4'h0};
  // P4 an operation operand
  assign o5 = reg2hw.cfg0.prescale.q + 12'd1;
  // P5 a select BASE
  assign o8 = din[reg2hw.cfg0.step.q];
  // P6 a cast operand
  assign o6 = 12'(reg2hw.cfg0.prescale.q);
  // P7 a system-call argument
  assign o7 = $unsigned(reg2hw.cfg0.prescale.q);
  // P8 a port High_conn
  snk91 u_snk (.a_i(reg2hw.cfg0.prescale.q), .z_o(o9));
  // P9 a procedural assignment
  logic [11:0] pr9;
  always_comb pr9 = reg2hw.cfg0.prescale.q;
  assign oa = pr9;
  // P10 a NESTED pattern (unpacked array of unpacked array)
  logic [11:0] nest [1][1];
  assign nest = '{'{reg2hw.cfg0.prescale.q}};
  assign ob = nest[0][0];
  // P11 a REPLICATED pattern
  logic [11:0] rep [2];
  assign rep = '{2{reg2hw.cfg0.prescale.q}};
  assign o2 = reg2hw.cfg0.step.q ^ rep[0][7:0] ^ rep[1][7:0];
endmodule
