// r10v193 (ADVERSARIAL VERIFIER) ARM B — THE RECEIVER FACE AND THE
// MUST-STAY FLOOR of § cloneArrayRecvArgMintsElemVar193.
//
// MEASUREMENT ONLY.  One real Surelog golden, both views; LHS is ALWAYS
// golden.
//
// The producer accepts a receiver that `any_cast<ref_obj*>` accepts — which
// by the UHDM class hierarchy is `ref_obj` AND its four subclasses
// `bit_select`, `part_select`, `indexed_part_select` and `var_select`, and
// NOT `ref_var` (which derives from `variables`).  The shipped drain accepts
// `ref_obj`, `bit_select` and `ref_var`: it is NARROWER on three subclasses
// (a STILL-WRONG at worst) and WIDER on `ref_var` (an AWAY if reachable).
// This arm writes both edges.
//
// It also carries THE MUST-STAY FLOOR in the same clone listing, so § 184's
// receiver-bind half and § retNameArgKeepsReturnVar184v are scored in the
// same census as this law's own cells:
//   B7  a PLAIN STRING receiver's argument MUST keep the RECEIVER;
//   B8  a free function's OWN RETURN NAME as a STRING receiver's argument
//       MUST keep the RETURN VARIABLE.

package Dock_v193;

  class Barge_v193;
    int m_load_v193;
    string m_tag_v193;
    int    m_bins_v193[int];
    function new(); m_load_v193 = 1; m_tag_v193 = "scow"; endfunction
    function int lift_v193(input int lug_v193);
      return lug_v193 + m_load_v193;
    endfunction
    // B5  a CLASS-PROPERTY array receiver inside an IN-BODY class method of a
    //     CLONED class — the shape the corpus never carries and arm D of the
    //     implementer's grid could only reach out of body (where Surelog
    //     itself errors).
    function int b5_prop_v193(input int fml_e_v193);
      if (m_bins_v193.exists(fml_e_v193)) fml_e_v193 = fml_e_v193 + 1;
      return fml_e_v193;
    endfunction
    // B6  the same receiver written through `this.` — a hier_path whose FIRST
    //     element is `this`, so the receiver sits at Path_elems[1].
    function int b6_this_v193(input int fml_f_v193);
      if (this.m_bins_v193.exists(fml_f_v193)) fml_f_v193 = fml_f_v193 + 1;
      return fml_f_v193;
    endfunction
  endclass

  // B1  a TWO-DIMENSIONAL unpacked array element as the receiver — a
  //     `var_select` in UHDM, which the producer accepts and the shipped
  //     drain does not.  MUST be a STILL-WRONG, never an AWAY.
  function automatic string b1_varsel_v193(input int fml_a_v193);
    string grid_v193[2][3];
    int    lug_v193;
    lug_v193 = 1;
    grid_v193[0][0] = "hawser";
    return grid_v193[0][1].substr(lug_v193, lug_v193);
  endfunction

  // B2  a QUEUE ELEMENT receiver reached through a `bit_select`, calling a
  //     USER-DEFINED method — the corpus's own `regs[j].get_address(this)`.
  function automatic int b2_qelem_v193(input int fml_b_v193);
    Barge_v193 tow_v193[$];
    Barge_v193 one_v193;
    int        lug_v193;
    one_v193 = new();
    tow_v193.push_back(one_v193);
    lug_v193 = 0;
    return fml_b_v193 + tow_v193[lug_v193].lift_v193(lug_v193);
  endfunction

  // B3  a receiver that is a plain CLASS HANDLE — not an array_var, so
  //     nothing may move.
  function automatic int b3_handle_v193(input int fml_c_v193);
    Barge_v193 solo_v193;
    int        lug_v193;
    solo_v193 = new();
    lug_v193 = 3;
    return fml_c_v193 + solo_v193.lift_v193(lug_v193);
  endfunction

  // B4  a receiver that is a FUNCTION CALL's result — not a `ref_obj` path
  //     element at all, so the producer never reaches it.
  function automatic int b4_callrecv_v193(input int fml_d_v193);
    Barge_v193 solo_v193;
    int        lug_v193;
    solo_v193 = new();
    lug_v193 = 4;
    return fml_d_v193 + solo_v193.m_tag_v193.len() + lug_v193;
  endfunction

  // B7  THE MUST-STAY FLOOR, § cloneBuiltinMethodArgBindsReceiver184: a plain
  //     STRING receiver's DIRECT argument binds THE RECEIVER, and it must be
  //     byte-identical on the pristine and the patched binary.
  function automatic string b7_strrecv_v193(input int fml_g_v193);
    string rode_v193;
    int    lug_v193;
    rode_v193 = "rodelaid";
    lug_v193 = 2;
    return rode_v193.substr(1, lug_v193);
  endfunction

  // B8  THE OTHER MUST-STAY, § retNameArgKeepsReturnVar184v: the free
  //     function's own RETURN NAME as a string receiver's argument keeps the
  //     RETURN VARIABLE and is NOT § 184's cell.
  function automatic int b8_retname_v193(input int fml_h_v193);
    string rode_v193;
    rode_v193 = "chainplate";
    b8_retname_v193 = 3;
    b8_retname_v193 = rode_v193.getc(b8_retname_v193);
    return b8_retname_v193 + fml_h_v193;
  endfunction

  // B9  a STRING ARRAY ELEMENT receiver whose slang type is a string (so
  //     § 184's site gate passes) but whose path element is a `bit_select`
  //     (so § 184's recorder refuses) — the seam between the two halves of
  //     the one producer.  Both halves must not write the same cell.
  function automatic string b9_seam_v193(input int fml_i_v193);
    string bight_v193[3];
    int    lug_v193;
    lug_v193 = 1;
    bight_v193[0] = "bightline";
    return bight_v193[0].substr(lug_v193, lug_v193);
  endfunction

endpackage

// THE CLONE listing.
package Quayside_v193;
  import Dock_v193::*;
  function automatic int shift_v193(input int fml_j_v193);
    return fml_j_v193;
  endfunction
endpackage

module topv193b;
  import Dock_v193::*;
  Barge_v193 hold_v193;
  int r_v193;
  string s_v193;
  initial begin
    hold_v193 = new();
    s_v193 = b1_varsel_v193(1);
    r_v193 = b2_qelem_v193(2) + b3_handle_v193(3) + b4_callrecv_v193(4)
           + hold_v193.b5_prop_v193(5) + hold_v193.b6_this_v193(6)
           + b8_retname_v193(8) + Quayside_v193::shift_v193(9);
    s_v193 = b7_strrecv_v193(7);
    s_v193 = b9_seam_v193(9);
  end
endmodule
