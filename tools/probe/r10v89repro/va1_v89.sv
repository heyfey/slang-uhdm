// r10v89 va1 — DIMENSION FACES x the head's leaf shape.  GOLDEN = Surelog.
// MEASUREMENT ONLY; the official uhdm-cmp stays the sole judge.
// Every row is the SAME leaf (`localparam int P_S = 3 + 1` — the head's shape,
// an expression initializer that reaches the REDUCED arm) with its `int
// unsigned` twin as the built-in negative control, worn by a DIFFERENT
// dimension face: size form, [P-1:0], [0:P-1], [P:0], expression sizes,
// literals, 2-D mixes, packed dims, queue/dynamic/associative, a typedef's
// dim and a net's dim.
module va1_89;
  localparam int          P_S = 3 + 1;
  localparam int unsigned P_U = 3 + 1;
  localparam int          Q_S = 2;

  // ---- the size form: the arm the law changes -------------------------
  logic [3:0] f_size_s [P_S];
  logic [3:0] f_size_u [P_U];

  // ---- EXPLICIT RANGES: a different builder path, must not move -------
  logic [3:0] f_dn_s   [P_S-1:0];
  logic [3:0] f_dn_u   [P_U-1:0];
  logic [3:0] f_up_s   [0:P_S-1];
  logic [3:0] f_up_u   [0:P_U-1];
  logic [3:0] f_pz_s   [P_S:0];
  logic [3:0] f_p1_s   [P_S:1];
  logic [3:0] f_bare_s [P_S:P_S];

  // ---- EXPRESSION size forms: no bare parameter leaf ------------------
  logic [3:0] f_sum_s  [P_S+Q_S];
  logic [3:0] f_mul_s  [P_S*2];
  logic [3:0] f_par_s  [(P_S)];
  logic [3:0] f_cst_s  [int'(P_S)];
  logic [3:0] f_cl_s   [$clog2(P_S)+3];

  // ---- LITERALS: MUST STAY BARE ---------------------------------------
  logic [3:0] f_lit    [8];
  logic [3:0] f_lit_r  [7:0];
  logic [3:0] f_lit_2  [4][2];

  // ---- MULTI-DIMENSION MIXES ------------------------------------------
  logic [3:0] f_2d_ss  [P_S][Q_S];
  logic [3:0] f_2d_su  [P_S][P_U];
  logic [3:0] f_2d_sr  [P_S][0:Q_S-1];
  logic [3:0] f_2d_rs  [0:P_S-1][P_S];
  logic [3:0] f_3d_s   [P_S][P_U][Q_S];

  // ---- PACKED dims: a different builder entirely ----------------------
  logic [P_S-1:0]           f_pk_s;
  logic [P_U-1:0]           f_pk_u;
  logic [P_S-1:0][Q_S-1:0]  f_pk2_s;
  logic signed [P_S-1:0]    f_pk_sg;

  // ---- QUEUE / DYNAMIC / ASSOCIATIVE ----------------------------------
  logic [3:0] f_q_b   [$:P_S];
  logic [3:0] f_q_n   [$];
  logic [3:0] f_dyn   [];
  logic [3:0] f_aa_i  [int];
  logic [3:0] f_aa_p  [logic [P_S-1:0]];

  // ---- a TYPEDEF's dim, both faces ------------------------------------
  typedef logic [3:0] td_s_t [P_S];
  typedef logic [3:0] td_u_t [P_U];
  typedef logic [3:0] td_r_t [P_S-1:0];
  td_s_t f_td_s;
  td_u_t f_td_u;
  td_r_t f_td_r;

  // ---- a NET's dim, both faces ----------------------------------------
  wire  [3:0] f_net_s [P_S];
  wire  [3:0] f_net_u [P_U];
  wire  [3:0] f_net_r [P_S-1:0];
endmodule
