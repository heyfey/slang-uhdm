// r10v193 (ADVERSARIAL VERIFIER) ARM D — THE LISTING AXIS of
// § cloneArrayRecvArgMintsElemVar193.
//
// MEASUREMENT ONLY.  One real Surelog golden, both views; LHS is ALWAYS
// golden.
//
// The shipped drain's listing gate is § 16's registry `pkgImportCloneTfs16`
// of WILDCARD-import clone subroutines, reached by a `VpiParent` walk that
// stops at the first listing root.  This arm asks what happens at every other
// listing face at once, in ONE golden:
//
//   D1  the HOME package's own body (must NOT move on either view);
//   D2  a package wildcard-imported by TWO packages (two clone listings of
//       the same body — the corpus's own shape, where a last-writer census
//       would drop one);
//   D3  a package wildcard-imported by a MODULE only;
//   D4  a CLASS METHOD of a cloned class (the corpus's own
//       `uvm_phase::sync` / `uvm_reg_map::do_print` shape);
//   D5  a package that is NEVER imported anywhere (nothing may fire);
//   D6  an EXPLICIT single-item import (residue R1 — must not move, and must
//       not move the wrong way either).

package Berth_v193;

  class Warp_v193;
    int m_slack_v193;
    function new(); m_slack_v193 = 1; endfunction
    // D4  a CLASS METHOD with an array receiver, cloned with its class.
    function int d4_meth_v193(input int fml_d_v193);
      int chain_v193[int];
      chain_v193[fml_d_v193] = 1;
      if (chain_v193.exists(fml_d_v193)) fml_d_v193 = fml_d_v193 + 1;
      return fml_d_v193 + m_slack_v193;
    endfunction
  endclass

  // D1/D2/D3  the same free function, seen from every listing.
  function automatic int d1_free_v193(input int fml_a_v193);
    int chain_v193[int];
    int shackle_v193;
    shackle_v193 = 1;
    chain_v193[shackle_v193] = 1;
    if (chain_v193.exists(shackle_v193)) fml_a_v193 = fml_a_v193 + 1;
    return fml_a_v193;
  endfunction

  // D6  the explicit-import face gets its own body so R1 is scored alone.
  function automatic int d6_explicit_v193(input int fml_f_v193);
    int chain_v193[int];
    int shackle_v193;
    shackle_v193 = 6;
    chain_v193[shackle_v193] = 6;
    if (chain_v193.exists(shackle_v193)) fml_f_v193 = fml_f_v193 + 1;
    return fml_f_v193;
  endfunction

endpackage

// D5  NEVER imported anywhere.
package Bollard_v193;
  function automatic int d5_lonely_v193(input int fml_e_v193);
    int chain_v193[int];
    int shackle_v193;
    shackle_v193 = 5;
    chain_v193[shackle_v193] = 5;
    if (chain_v193.exists(shackle_v193)) fml_e_v193 = fml_e_v193 + 1;
    return fml_e_v193;
  endfunction
endpackage

// D2  TWO wildcard-import clone listings of the same body.
package Mooring_v193;
  import Berth_v193::*;
  function automatic int hitch_v193(input int fml_g_v193);
    return fml_g_v193;
  endfunction
endpackage

package Painter_v193;
  import Berth_v193::*;
  function automatic int belay_v193(input int fml_h_v193);
    return fml_h_v193;
  endfunction
endpackage

// D6  the EXPLICIT single-item import.
package Grommet_v193;
  import Berth_v193::d6_explicit_v193;
  function automatic int thread_v193(input int fml_i_v193);
    return fml_i_v193;
  endfunction
endpackage

// D3  a MODULE-only wildcard import.
module topv193d;
  import Berth_v193::*;
  Warp_v193 rig_v193;
  int r_v193;
  initial begin
    rig_v193 = new();
    r_v193 = d1_free_v193(1) + d6_explicit_v193(6) + rig_v193.d4_meth_v193(4)
           + Bollard_v193::d5_lonely_v193(5) + Mooring_v193::hitch_v193(7)
           + Painter_v193::belay_v193(8) + Grommet_v193::thread_v193(9);
  end
endmodule
