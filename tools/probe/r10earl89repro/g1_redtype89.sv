// r10earl89 g1 — THE SIZING PARAMETER'S DECLARED TYPE x ITS INITIALIZER FORM,
// on a module-body unpacked dimension.  GOLDEN = Surelog.
// MEASUREMENT ONLY.  12 declared types x 4 initializer forms = 48 cells.
// The initializer form is the discriminator our emitter's "reduced" arm keys
// on (a literal / a bare ref / an expression / a system call), the declared
// type is the one the typespec stamp keys on.
module g1_89;
  localparam int BASE = 4;

  // ---- int -------------------------------------------------------------
  localparam int         a_int_lit = 4;         logic [3:0] v_int_lit [a_int_lit];
  localparam int         a_int_ref = BASE;      logic [3:0] v_int_ref [a_int_ref];
  localparam int         a_int_exp = BASE + 1;  logic [3:0] v_int_exp [a_int_exp];
  localparam int         a_int_sys = $clog2(64);logic [3:0] v_int_sys [a_int_sys];

  // ---- int unsigned ----------------------------------------------------
  localparam int unsigned a_iu_lit = 4;         logic [3:0] v_iu_lit [a_iu_lit];
  localparam int unsigned a_iu_ref = BASE;      logic [3:0] v_iu_ref [a_iu_ref];
  localparam int unsigned a_iu_exp = BASE + 1;  logic [3:0] v_iu_exp [a_iu_exp];
  localparam int unsigned a_iu_sys = $clog2(64);logic [3:0] v_iu_sys [a_iu_sys];

  // ---- logic [7:0] (unsigned) -----------------------------------------
  localparam logic [7:0] a_lg_lit = 4;          logic [3:0] v_lg_lit [a_lg_lit];
  localparam logic [7:0] a_lg_ref = BASE;       logic [3:0] v_lg_ref [a_lg_ref];
  localparam logic [7:0] a_lg_exp = BASE + 1;   logic [3:0] v_lg_exp [a_lg_exp];
  localparam logic [7:0] a_lg_sys = $clog2(64); logic [3:0] v_lg_sys [a_lg_sys];

  // ---- logic signed [7:0] ---------------------------------------------
  localparam logic signed [7:0] a_ls_lit = 4;         logic [3:0] v_ls_lit [a_ls_lit];
  localparam logic signed [7:0] a_ls_ref = BASE;      logic [3:0] v_ls_ref [a_ls_ref];
  localparam logic signed [7:0] a_ls_exp = BASE + 1;  logic [3:0] v_ls_exp [a_ls_exp];
  localparam logic signed [7:0] a_ls_sys = $clog2(64);logic [3:0] v_ls_sys [a_ls_sys];

  // ---- bit [7:0] -------------------------------------------------------
  localparam bit [7:0]   a_bt_lit = 4;          logic [3:0] v_bt_lit [a_bt_lit];
  localparam bit [7:0]   a_bt_ref = BASE;       logic [3:0] v_bt_ref [a_bt_ref];
  localparam bit [7:0]   a_bt_exp = BASE + 1;   logic [3:0] v_bt_exp [a_bt_exp];
  localparam bit [7:0]   a_bt_sys = $clog2(64); logic [3:0] v_bt_sys [a_bt_sys];

  // ---- bit signed [7:0] ------------------------------------------------
  localparam bit signed [7:0] a_bs_lit = 4;         logic [3:0] v_bs_lit [a_bs_lit];
  localparam bit signed [7:0] a_bs_ref = BASE;      logic [3:0] v_bs_ref [a_bs_ref];
  localparam bit signed [7:0] a_bs_exp = BASE + 1;  logic [3:0] v_bs_exp [a_bs_exp];
  localparam bit signed [7:0] a_bs_sys = $clog2(64);logic [3:0] v_bs_sys [a_bs_sys];

  // ---- implicit (untyped) ---------------------------------------------
  localparam             a_un_lit = 4;          logic [3:0] v_un_lit [a_un_lit];
  localparam             a_un_ref = BASE;       logic [3:0] v_un_ref [a_un_ref];
  localparam             a_un_exp = BASE + 1;   logic [3:0] v_un_exp [a_un_exp];
  localparam             a_un_sys = $clog2(64); logic [3:0] v_un_sys [a_un_sys];

  // ---- implicit with an explicit `signed` keyword ----------------------
  localparam signed [7:0] a_sg_lit = 4;         logic [3:0] v_sg_lit [a_sg_lit];
  localparam signed [7:0] a_sg_ref = BASE;      logic [3:0] v_sg_ref [a_sg_ref];
  localparam signed [7:0] a_sg_exp = BASE + 1;  logic [3:0] v_sg_exp [a_sg_exp];
  localparam signed [7:0] a_sg_sys = $clog2(64);logic [3:0] v_sg_sys [a_sg_sys];

  // ---- integer ---------------------------------------------------------
  localparam integer     a_ig_lit = 4;          logic [3:0] v_ig_lit [a_ig_lit];
  localparam integer     a_ig_ref = BASE;       logic [3:0] v_ig_ref [a_ig_ref];
  localparam integer     a_ig_exp = BASE + 1;   logic [3:0] v_ig_exp [a_ig_exp];
  localparam integer     a_ig_sys = $clog2(64); logic [3:0] v_ig_sys [a_ig_sys];

  // ---- shortint --------------------------------------------------------
  localparam shortint    a_sh_lit = 4;          logic [3:0] v_sh_lit [a_sh_lit];
  localparam shortint    a_sh_ref = BASE;       logic [3:0] v_sh_ref [a_sh_ref];
  localparam shortint    a_sh_exp = BASE + 1;   logic [3:0] v_sh_exp [a_sh_exp];
  localparam shortint    a_sh_sys = $clog2(64); logic [3:0] v_sh_sys [a_sh_sys];

  // ---- longint ---------------------------------------------------------
  localparam longint     a_ln_lit = 4;          logic [3:0] v_ln_lit [a_ln_lit];
  localparam longint     a_ln_ref = BASE;       logic [3:0] v_ln_ref [a_ln_ref];
  localparam longint     a_ln_exp = BASE + 1;   logic [3:0] v_ln_exp [a_ln_exp];
  localparam longint     a_ln_sys = $clog2(64); logic [3:0] v_ln_sys [a_ln_sys];

  // ---- byte ------------------------------------------------------------
  localparam byte        a_by_lit = 4;          logic [3:0] v_by_lit [a_by_lit];
  localparam byte        a_by_ref = BASE;       logic [3:0] v_by_ref [a_by_ref];
  localparam byte        a_by_exp = BASE + 1;   logic [3:0] v_by_exp [a_by_exp];
  localparam byte        a_by_sys = $clog2(64); logic [3:0] v_by_sys [a_by_sys];

  // ---- the built-in NEGATIVE CONTROL: a literal-sized dimension --------
  logic [3:0] v_ctl_lit [8];
endmodule
