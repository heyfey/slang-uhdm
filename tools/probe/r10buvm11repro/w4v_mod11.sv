// r10buvm11 arm w4 — THE MODULE-SCOPE TWIN of arm w1's dim grid, plus the
// element-kind fence at module scope.  This arm exists to decide whether the
// law's second production site (TypeEmit.cpp `emitDynArrayVar`, the
// module/package instance-level array_var) is IN SCOPE or a residue: it can
// only be in scope where the array_var already carries the ranges golden gives
// it.  MEASUREMENT ONLY.
module w4v_mod11_top;
  typedef bit       b_t;
  typedef bit [7:0] bv_t;
  // ---- 1-D unsized controls
  bit m_a1   [int];
  bit m_d1   [];
  bit m_q1   [$];
  // ---- 2-D leading-unsized, REMAINING dim FIXED (the array_var DOES get
  // ranges from us today: `fixRanges && leadingUnsized`)
  bit m_df   [][2];
  bit m_qf   [$][2];
  bit m_af   [int][2];
  bit m_dff  [][2][3];
  // ---- 2-D leading-unsized, remaining dim UNSIZED
  bit m_aa   [int][int];
  bit m_dd   [][];
  bit m_qq   [$][$];
  // ---- leading FIXED
  bit m_fd   [2][];
  bit m_fa   [2][int];
  // ---- FIXED only
  bit m_f1   [4];
  bit m_f2   [2][3];
  // ---- element-kind fence at the `[][2]` shape
  logic     n_log  [][2];
  int       n_int  [][2];
  byte      n_byte [][2];
  string    n_str  [][2];
  real      n_real [][2];
  b_t       n_btd  [][2];
  bv_t      n_bvtd [][2];
  bit [7:0] n_bitv [][2];
  // ---- the FIXED-array element-kind fence at module scope: the site whose
  // law ALREADY ships (TypeEmit.cpp emitArrayVar).  A typedef'd bit element is
  // the cell that separates the class-scope gate from the module-scope one.
  bit       f_bit  [4];
  b_t       f_btd  [4];
  bv_t      f_bvtd [4];
  bit [7:0] f_bitv [4];
  logic     f_log  [4];
  initial begin
    m_a1[0] = 1'b1;
  end
endmodule
