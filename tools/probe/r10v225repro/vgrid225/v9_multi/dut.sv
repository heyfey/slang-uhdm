// r10v225 arm v9_multi — a typedef-HIDDEN dimension and a WRITTEN dimension on
// top of it (the `a14_tdhide` face, widened).  MEASURED: a typedef whose target
// is a DYNAMIC, QUEUE or ASSOCIATIVE array is an `unsupported construct` on
// BOTH binaries ("typedef target: DynamicArrayType" …), so only the FIXED
// hidden form is reachable — the same fence family as r10uvm225's R6 and
// r10v224's R-D.
interface if225v_hid();
  typedef logic [7:0] tvn_t;
  typedef tvn_t hf_t [1:0];    // hidden FIXED
  typedef hf_t  hh_t [2];      // hidden FIXED, two levels
  hf_t  h_fix;
  hh_t  h_fix2;
  hf_t  h_fix_w  [2];
  hh_t  h_fix2_w [3];
  hf_t  h_fix_d  [];
  hf_t  h_fix_a  [string];
  tvn_t h_plain  [2];
endinterface

module top225v_hid(); endmodule
