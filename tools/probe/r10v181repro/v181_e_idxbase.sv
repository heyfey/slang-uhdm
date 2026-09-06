// r10v181 arm E -- THE MINIMAL ELAB CELL the identity instrument found.
//
// In the ELAB view of a wildcard-import clone, golden emits TWO copies of the
// clone body.  In ONE of them a foreach loop variable used as the INDEX of a
// hier_path BASE (`arr[i].member`) binds the loop's LISTING `ref_var` itself
// rather than the law cloneLoopVarShared37 object hanging off it, while the
// call-argument occurrences of the same name bind the shared object.  The
// pristine binary reached that one cell by accident (it bound the index and
// left the call arguments bare); the patched binary binds all three to the
// shared object.  This arm is that cell alone, so `uhdm-cmp` is not masked by
// any earlier head and can say whether the difference is one the JUDGE reads.
//
// DEF view: golden binds ALL THREE to the shared object and the patched binary
// matches it exactly -- so this arm is also the def-side positive control.
package cresset_home;

  typedef struct packed { logic [3:0] tallow; logic [3:0] rushlight; } sconce_t;

  class linstock_cls;
    int      linstock_arr [3];
    sconce_t linstock_structarr [3];
    extern function int betony181_empty();
  endclass

  function int linstock_cls::betony181_empty();
    foreach (linstock_arr[wickyard]) begin
      int fusee;
      fusee = int'(linstock_structarr[wickyard].rushlight);
      betony181_empty = fusee;
    end
  endfunction

endpackage

package cresset_imp;
  import cresset_home::*;
  int cresset_anchor;
endpackage

module cresset_top;
  initial cresset_imp::cresset_anchor = 0;
endmodule
