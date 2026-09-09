// r10v225 arm v5_holders — THE UNVECTORED HOLDERS, adversarially.  Nothing but
// an interface definition may grow an Array_nets() entry: a package, a module
// (both header forms), a program and an interface all declare the same
// containers.
package p225v;
  typedef logic [7:0] tvp_t;
  tvp_t pk_fix [1:0];
  tvp_t pk_dyn [];
  tvp_t pk_q   [$];
  tvp_t pk_as  [string];
endpackage

module m225v_ep();
  typedef logic [7:0] tvm_t;
  tvm_t mm_fix [1:0];
  tvm_t mm_dyn [];
  tvm_t mm_q   [$];
  tvm_t mm_as  [string];
endmodule

module m225v_np;
  typedef logic [7:0] tvn_t;
  tvn_t mn_fix [1:0];
  tvn_t mn_dyn [];
  tvn_t mn_as  [string];
endmodule

program pr225v();
  typedef logic [7:0] tvr_t;
  tvr_t pp_fix [1:0];
  tvr_t pp_dyn [];
  tvr_t pp_as  [string];
endprogram

interface if225v_h();
  typedef logic [7:0] tvh_t;
  tvh_t hh_fix [1:0];
  tvh_t hh_dyn [];
  tvh_t hh_q   [$];
  tvh_t hh_as  [string];
endinterface

module top225v_h(); endmodule
