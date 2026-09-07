// r10v193 (ADVERSARIAL VERIFIER) ARM A — THE MINT'S ELEMENT-KIND AXIS of
// § cloneArrayRecvArgMintsElemVar193.
//
// MEASUREMENT ONLY.  One real Surelog golden, both views; LHS is ALWAYS
// golden.  The shipped `mintArrayElemVar193` copies SIXTEEN variable kinds
// with `*clone = *src` and REFUSES six (`array_var`, `packed_array_var`,
// `var_bit`, `ref_var`, `gen_var`, `virtual_interface_var`).  Four of the
// copied kinds own VECTORS that `*clone = *src` copies BY POINTER —
// `struct_var`/`union_var` (`Variables`, `Var_bits`) and
// `bit_var`/`logic_var` (`Ranges`, `Var_bits`) — and the shipped code
// re-vectors ONLY `Ranges`.  This arm makes every one of those kinds the
// ELEMENT of an array receiver so the copy is measured rather than argued,
// and adds the REFUSED `array_var` element (an array of arrays) as the
// STILL-WRONG control.
//
// Names carry the `_v193` suffix so this arm's census keys join nothing else.

package Wharf_v193;

  typedef struct { int limb_v193; int spar_v193; } Cleat_v193;
  typedef union  { int mast_v193; int keel_v193; } Boom_v193;
  typedef enum { TACK_V193, GYBE_V193 } Sheet_v193;

  class Hull_v193;
    int m_draft_v193;
    function new(); m_draft_v193 = 1; endfunction
  endclass

  // A1  STRUCT element  -> golden mints a struct_var; ours COPIES one whose
  //     `Variables()` vector is SHARED with the array's own element.
  function automatic int a1_struct_v193(input int fml_a_v193);
    Cleat_v193 hoard_v193[int];
    int        pin_v193;
    pin_v193 = 1;
    hoard_v193[pin_v193].limb_v193 = 2;
    if (hoard_v193.exists(pin_v193)) fml_a_v193 = fml_a_v193 + 1;
    return fml_a_v193;
  endfunction

  // A2  UNION element.
  function automatic int a2_union_v193(input int fml_b_v193);
    Boom_v193 stow_v193[int];
    int       pin_v193;
    pin_v193 = 2;
    stow_v193[pin_v193].mast_v193 = 3;
    if (stow_v193.exists(pin_v193)) fml_b_v193 = fml_b_v193 + 1;
    return fml_b_v193;
  endfunction

  // A3  LOGIC-VECTOR element -> a logic_var carrying a `Ranges` vector.
  function automatic int a3_logic_v193(input int fml_c_v193);
    logic [7:0] gang_v193[int];
    int         pin_v193;
    pin_v193 = 3;
    gang_v193[pin_v193] = 8'hAB;
    if (gang_v193.exists(pin_v193)) fml_c_v193 = fml_c_v193 + 1;
    return fml_c_v193;
  endfunction

  // A4  BIT-VECTOR element -> a bit_var carrying a `Ranges` vector.
  function automatic int a4_bit_v193(input int fml_d_v193);
    bit [3:0] clamp_v193[int];
    int       pin_v193;
    pin_v193 = 4;
    clamp_v193[pin_v193] = 4'h5;
    if (clamp_v193.exists(pin_v193)) fml_d_v193 = fml_d_v193 + 1;
    return fml_d_v193;
  endfunction

  // A5  ENUM element.
  function automatic int a5_enum_v193(input int fml_e_v193);
    Sheet_v193 flag_v193[int];
    int        pin_v193;
    pin_v193 = 5;
    flag_v193[pin_v193] = TACK_V193;
    if (flag_v193.exists(pin_v193)) fml_e_v193 = fml_e_v193 + 1;
    return fml_e_v193;
  endfunction

  // A6  REAL element.
  function automatic int a6_real_v193(input int fml_f_v193);
    real depth_v193[int];
    int  pin_v193;
    pin_v193 = 6;
    depth_v193[pin_v193] = 1.5;
    if (depth_v193.exists(pin_v193)) fml_f_v193 = fml_f_v193 + 1;
    return fml_f_v193;
  endfunction

  // A7  STRING element.
  function automatic int a7_string_v193(input int fml_g_v193);
    string label_v193[int];
    int    pin_v193;
    pin_v193 = 7;
    label_v193[pin_v193] = "warp";
    if (label_v193.exists(pin_v193)) fml_g_v193 = fml_g_v193 + 1;
    return fml_g_v193;
  endfunction

  // A8  CLASS element (the corpus's own `uvm_reg regs[$]` kind).
  function automatic int a8_class_v193(input int fml_h_v193);
    Hull_v193 fleet_v193[int];
    int       pin_v193;
    pin_v193 = 8;
    fleet_v193[pin_v193] = new();
    if (fleet_v193.exists(pin_v193)) fml_h_v193 = fml_h_v193 + 1;
    return fml_h_v193;
  endfunction

  // A9  ARRAY-OF-ARRAY element -> `array_var`, one of the SIX kinds
  //     `mintArrayElemVar193` REFUSES (residue R2).  The measurement this arm
  //     wants is that the refusal is a STILL-WRONG and never an AWAY.
  function automatic int a9_aoa_v193(input int fml_i_v193);
    int nest_v193[int][int];
    int pin_v193;
    pin_v193 = 9;
    nest_v193[pin_v193][0] = 1;
    if (nest_v193.exists(pin_v193)) fml_i_v193 = fml_i_v193 + 1;
    return fml_i_v193;
  endfunction

  // A10 BYTE element, for a kind with no vector at all (control).
  function automatic int a10_byte_v193(input int fml_j_v193);
    byte crumb_v193[int];
    int  pin_v193;
    pin_v193 = 10;
    crumb_v193[pin_v193] = 8'd7;
    if (crumb_v193.exists(pin_v193)) fml_j_v193 = fml_j_v193 + 1;
    return fml_j_v193;
  endfunction

endpackage

// THE CLONE listing.
package Slip_v193;
  import Wharf_v193::*;
  function automatic int haul_v193(input int fml_k_v193);
    return fml_k_v193;
  endfunction
endpackage

module topv193a;
  import Wharf_v193::*;
  int r_v193;
  initial begin
    r_v193 = a1_struct_v193(1) + a2_union_v193(2) + a3_logic_v193(3)
           + a4_bit_v193(4) + a5_enum_v193(5) + a6_real_v193(6)
           + a7_string_v193(7) + a8_class_v193(8) + a9_aoa_v193(9)
           + a10_byte_v193(10) + Slip_v193::haul_v193(11);
  end
endmodule
