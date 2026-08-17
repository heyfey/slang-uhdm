// r10buvm11 arm w1 — THE DIM-SHAPE GRID at the head's own home (a class
// property in a package), element `bit` throughout, so the ONLY variable is the
// written dimension list.  MEASUREMENT ONLY.
package pk11;
  class kcls11;
    int k;
  endclass
  class w1_cls;
    // ---- 1-D unsized: the array_var keeps NO range, so Surelog's shared
    // vector is EMPTY and serialization drops it.  CONTROLS.
    bit d_assoc_int  [int];
    bit d_assoc_str  [string];
    bit d_assoc_cls  [kcls11];
    bit d_dyn        [];
    bit d_queue      [$];
    // ---- 2-D, LEADING unsized: the head's family.
    bit d_aa_ii      [int][int];
    bit d_aa_is      [int][string];
    bit d_aa_cc      [kcls11][kcls11];
    bit d_dd         [][];
    bit d_qq         [$][$];
    bit d_aq         [int][$];
    bit d_qa         [$][int];
    bit d_da         [][int];
    bit d_ad         [int][];
    // ---- 3-D
    bit d_aaa        [int][int][int];
    // ---- mixed with FIXED dims
    bit d_af         [int][2];
    bit d_fa         [2][int];
    bit d_df         [][2];
    bit d_fd         [2][];
    bit d_qf         [$][2];
    bit d_fq         [2][$];
    bit d_aff        [int][2][3];
    bit d_ffa        [2][3][int];
    // ---- FIXED only
    bit d_f1         [4];
    bit d_f2         [2][3];
    bit d_frng       [0:3];
  endclass
endpackage
module w1v_dims11_top;
  pk11::w1_cls u = new();
endmodule
