// t51a — pass 37, cell A: WHAT does golden bind inside a WILDCARD-IMPORT
// CLONE body, beyond the hier_path base / method-call prefix § pkgCloneHierBind9
// already covers?
//
// SeqDriver's 3171 binding MISSES are 88% adpcm_pkg (the
// `package adpcm_pkg; import uvm_pkg::*;` clone bodies), mirrored between the
// DEF and ELAB views, and by golden's target they are the clone body's OWN
// locals and LOOP VARIABLES reached through ORDINARY refs:
//     DEFPKG adpcm_pkg::uvm_reg_block::do_print | ref_obj 'i' -> ref_var:i
//     DEFPKG adpcm_pkg::uvm_root::m_do_config_settings | ref_var 'args'
//                                                     -> array_var:args
//     DEFPKG adpcm_pkg::uvm_default_factory::print
//         | bit_select 'sorted_override_queues' -> array_var:...
// while the SAME reference in the home package's own DEF listing is null in
// golden AND in ours (4-cell control, read off the corpus).
//
// This cell asks the same question of a purpose-built golden and carries the
// NEGATIVES in the same file:
//   * a CLASS METHOD (the dominant population: an importer's DEF package view
//     lists clones of the imported package's class methods) and a FREE
//     FUNCTION side by side
//   * a foreach LOOP VARIABLE used as a bit_select index and as a plain rvalue
//   * a body LOCAL, a body local ARRAY (as a bit_select base and as the
//     foreach array), and a FORMAL
//   * the negatives: a CLASS PROPERTY and `this` (golden's clone leaves those
//     null per § pkgCloneHierBind9's own census note), and the IMPLICIT
//     FUNCTION-RETURN variable (the EXTRA side: we bind `f51 = ...` where
//     golden leaves it bare)
//   * a nested BLOCK-local declaration, to check the shadowing order survives
//
// Read with r10uvm28g: every reference in the design keyed by VIEW + enclosing
// task_func + line:col, carrying its Actual_group.

package home51;

  class c51;
    int prop;
    int arr[4];

    function int m51(int n);
      int acc;
      acc = 0;
      // loop var `i`: as a bit_select index AND as a plain rvalue
      foreach (arr[i])
        acc = acc + arr[i] + i;
      // a for-loop local
      for (int k = 0; k < n; k++)
        acc = acc + k;
      // NEGATIVE: a class PROPERTY and `this`
      acc = acc + prop + this.prop;
      // a nested block-local shadowing nothing
      begin
        int blk;
        blk = acc;
        acc = blk;
      end
      // the FORMAL, plain
      acc = acc + n;
      // IMPLICIT RETURN VARIABLE (the EXTRA side)
      m51 = acc;
      return acc;
    endfunction
  endclass

  // free function: an importer clones this into its DEF *and* ELAB listings
  function automatic int f51(int n);
    int acc2;
    int arr2[4];
    acc2 = 0;
    foreach (arr2[j])
      acc2 = acc2 + arr2[j] + j;
    acc2 = acc2 + n;
    f51 = acc2;
  endfunction

endpackage

package imp51;
  import home51::*;
  function automatic int g51(int m);
    c51 o;
    o = new();
    return o.m51(m) + f51(m);
  endfunction
endpackage

module mm51;
  import home51::*;
  int q;
  initial q = f51(3);
endmodule
