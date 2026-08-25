// r10earl89 g4 — THE EDGES OF THE TWO CONJUNCTS.  GOLDEN = Surelog.
// (a) IMPLICIT declarations with a RANGE and/or a `signed` keyword — does the
//     parameter have a compiled typespec at all (the `ts == nullptr` half of
//     DesignElaboration.cpp:2536, which is why an untyped parameter never
//     stamps);
// (b) TYPEDEF'd and ENUM'd declared types — kinds valueRange's three-arm
//     switch does NOT name;
// (c) non-integral parameters (real / string / time) — the negative controls;
// (d) a genvar-derived localparam and a for-generate home.
package s89;
  typedef int          si_t;
  typedef int unsigned su_t;
  typedef logic signed [7:0] sl_t;
  typedef logic        [7:0] su8_t;
endpackage

module g4_89;
  import s89::*;
  localparam int          B_S = 4;
  localparam int unsigned B_U = 4;

  // (a) IMPLICIT shapes -------------------------------------------------
  localparam [7:0]        i_rng_lit = 4;    logic [3:0] v_i_rng_lit [i_rng_lit];
  localparam [7:0]        i_rng_ref = B_S;  logic [3:0] v_i_rng_ref [i_rng_ref];
  localparam [7:0]        i_rng_exp = B_S+1;logic [3:0] v_i_rng_exp [i_rng_exp];
  localparam signed       i_sgn_lit = 4;    logic [3:0] v_i_sgn_lit [i_sgn_lit];
  localparam signed       i_sgn_exp = B_S+1;logic [3:0] v_i_sgn_exp [i_sgn_exp];
  localparam unsigned     i_uns_exp = B_S+1;logic [3:0] v_i_uns_exp [i_uns_exp];
  localparam signed [7:0] i_sr_ref  = B_U;  logic [3:0] v_i_sr_ref  [i_sr_ref];

  // (b) TYPEDEF'd and ENUM'd declared types -----------------------------
  localparam si_t         t_si_lit = 4;     logic [3:0] v_t_si_lit [t_si_lit];
  localparam si_t         t_si_exp = B_S+1; logic [3:0] v_t_si_exp [t_si_exp];
  localparam su_t         t_su_exp = B_S+1; logic [3:0] v_t_su_exp [t_su_exp];
  localparam sl_t         t_sl_exp = B_S+1; logic [3:0] v_t_sl_exp [t_sl_exp];
  localparam su8_t        t_su8_exp= B_S+1; logic [3:0] v_t_su8_exp[t_su8_exp];
  typedef enum int { E0 = 4, E1 = 5 } e89_t;
  localparam e89_t        t_en_lit = E1;    logic [3:0] v_t_en_lit [t_en_lit];

  // (c) NEGATIVE controls: literal dims and a nested-select dim ----------
  logic [3:0] v_ctl_lit [8];
  logic [3:0] v_ctl_exp [B_S + 1];

  // (d) GENVAR-derived localparams --------------------------------------
  for (genvar gj = 0; gj < 2; gj++) begin : gc
    localparam int          j_s = gj + 4;
    localparam int unsigned j_u = gj + 4;
    logic [3:0] v_j_s [j_s];
    logic [3:0] v_j_u [j_u];
    localparam int          j_r = B_S;
    logic [3:0] v_j_r [j_r];
  end
endmodule
