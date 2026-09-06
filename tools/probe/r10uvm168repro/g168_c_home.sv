// r10uvm168repro/g168_c_home.sv — MEASUREMENT ONLY.
// ARM C: the HOME.  The same three enum-reference shapes (auto-numbered
// member / based-decimal member / octal member) in every scope a parameter can
// live in — package, a package that imports another package, module, generate
// scope, interface, class, and the compilation unit — so the law's reach is
// measured where it fires AND where it must not.
package thicket_pkg;
  typedef enum { LANTERN_OFF, LANTERN_DIM, LANTERN_FULL } lantern_e;
  typedef enum bit [3:0] { RATCHET_TWO = 4'd2, RATCHET_NEXT } ratchet_e;
  typedef enum logic [5:0] { SPINDLE_ODD = 6'o17, SPINDLE_NEXT } spindle_e;
  parameter lantern_e kc_p_auto = LANTERN_FULL;   // c01
  parameter ratchet_e kc_p_bdec = RATCHET_TWO;    // c02
  parameter spindle_e kc_p_oct  = SPINDLE_ODD;    // c03
  parameter lantern_e kc_p_hop  = kc_p_auto;      // c04
endpackage

// A package that IMPORTS another and re-exports the same three shapes.
package brambel_pkg;
  import thicket_pkg::*;
  parameter lantern_e kc_q_auto = LANTERN_DIM;    // c11
  parameter ratchet_e kc_q_bdec = RATCHET_NEXT;   // c12
  parameter spindle_e kc_q_oct  = SPINDLE_ODD;    // c13
  parameter lantern_e kc_q_cross = thicket_pkg::kc_p_auto;  // c14
  typedef enum { HALYARD_A, HALYARD_B } halyard_e;
  parameter halyard_e kc_q_own  = HALYARD_B;      // c15
endpackage

interface tiller_if;
  import thicket_pkg::*;
  parameter lantern_e kc_i_auto = LANTERN_FULL;   // c21
  localparam ratchet_e kc_i_bdec = RATCHET_TWO;   // c22
endinterface

module gantry_mod;
  import thicket_pkg::*;
  parameter lantern_e kc_m_auto = LANTERN_FULL;   // c31
  parameter ratchet_e kc_m_bdec = RATCHET_TWO;    // c32
  parameter spindle_e kc_m_oct  = SPINDLE_ODD;    // c33
  localparam lantern_e kc_m_lp  = LANTERN_DIM;    // c34
  localparam lantern_e kc_m_hop = kc_m_auto;      // c35

  // A GENERATE scope's own localparams, flat and nested.
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : rung
      localparam lantern_e kc_g_auto = LANTERN_FULL;  // c41
      localparam ratchet_e kc_g_bdec = RATCHET_TWO;   // c42
      if (gi == 0) begin : deep
        localparam lantern_e kc_gg_auto = LANTERN_DIM; // c43
      end
    end
  endgenerate

  // A CLASS home.
  class Fathom;
    localparam lantern_e kc_k_auto = LANTERN_FULL;   // c51
    localparam ratchet_e kc_k_bdec = RATCHET_TWO;    // c52
    lantern_e m_state = LANTERN_DIM;                 // c53 (a VARIABLE init, not a param)
  endclass

  tiller_if u_tiller();

  // A CHILD instance whose parameter ACTUAL is an enum member.
  spar_mod #(.KC_ACT(LANTERN_FULL)) u_spar ();      // c61
endmodule

module spar_mod #(parameter thicket_pkg::lantern_e KC_ACT = thicket_pkg::LANTERN_OFF);
  localparam thicket_pkg::lantern_e kc_s_use = KC_ACT;  // c62
endmodule

// The COMPILATION UNIT ($unit) home.
parameter thicket_pkg::lantern_e kc_u_auto = thicket_pkg::LANTERN_FULL;  // c71
