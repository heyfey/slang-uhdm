// r10uvm182 arm A — THE METHOD × RECEIVER-KIND GRID for a parens-less
// built-in read inside a WILDCARD-IMPORT CLONE BODY.
//
// The law under test lives in UHDM's `hier_path::DeepClone`
// (~/git-repos/UHDM/templates/clone_tree.cpp): when the PRECEDING path element
// resolved to an `array_var` / `packed_array_var` / `array_net` /
// `packed_array_net`, an element named one of EXACTLY
//     size  exists  find  max  min
// binds its `vpiActual` to a NEWLY MINTED, SPAN-LESS `func_call` of that name
// parented at the cloned hier_path.  Every other method name falls through and
// stays BARE.  So each cell here is one method name against one receiver kind,
// and the NEGATIVE names sit in the same file, in the same functions, read the
// same way — an arm that agrees must agree for a reason.
//
// `bard182_home` is the home; `bard182_imp` wildcard-imports it and therefore
// CLONES every free function below.  The arrays are FUNCTION LOCALS because the
// binding of the BASE element is itself a clone-body-locals rule (r10uvm181's
// § pkgCloneBodyLocals): a package-level array would leave the base unbound and
// the law would never be reached, which is exactly what the `bard182_pkgarr_fn`
// control measures.
//
// Names are unlike the corpus's (`q`, `qq`, `m_recur_states`) and unlike each
// other, so a cell that lands cannot be landing on a corpus-shaped coincidence.
package bard182_home;

  typedef struct { int gantry; int wicket; } lodge182_t;

  int bard182_pkgfixed [$];

  // ---- FIXED UNPACKED receiver, the five IN names and five OUT names ----
  function automatic int fixed182_fn();
    int  cusp [6];
    int  bay  [$];
    int  hob;
    bay = cusp.max;          // A_fixed_max     IN
    bay = cusp.min;          // A_fixed_min     IN
    hob = cusp.sum;          // A_fixed_sum     OUT
    hob = cusp.product;      // A_fixed_product OUT
    hob = cusp.xor;          // A_fixed_xor     OUT
    bay = cusp.unique;       // A_fixed_unique  OUT
    return hob + bay.size;
  endfunction

  // ---- QUEUE receiver ---------------------------------------------------
  function automatic int queue182_fn();
    int  lull [$];
    int  bay  [$];
    int  hob;
    bay = lull.max;          // A_queue_max     IN
    bay = lull.min;          // A_queue_min     IN
    hob = lull.size;         // A_queue_size    IN
    hob = lull.sum;          // A_queue_sum     OUT
    bay = lull.unique;       // A_queue_unique  OUT
    return hob + bay.size;
  endfunction

  // ---- DYNAMIC receiver -------------------------------------------------
  function automatic int dyn182_fn();
    int  mote [];
    int  bay  [$];
    int  hob;
    bay = mote.max;          // A_dyn_max       IN
    hob = mote.size;         // A_dyn_size      IN
    hob = mote.sum;          // A_dyn_sum       OUT
    return hob + bay.size;
  endfunction

  // ---- ASSOCIATIVE receiver ---------------------------------------------
  function automatic int assoc182_fn();
    int  trove [string];
    int  bay   [$];
    int  hob;
    bay = trove.max;         // A_assoc_max     IN
    bay = trove.min;         // A_assoc_min     IN
    hob = trove.size;        // A_assoc_size    IN
    hob = trove.num;         // A_assoc_num     OUT
    return hob + bay.size;
  endfunction

  // ---- QUEUE OF STRUCT receiver (an aggregate element type) --------------
  function automatic int strq182_fn();
    lodge182_t sill [$];
    int        hob;
    hob = sill.size;         // A_strq_size     IN
    return hob;
  endfunction

  // ---- STRING receiver: NOT an array_var — the whole family must refuse ---
  function automatic int strr182_fn();
    string apse;
    int    hob;
    apse = "voussoir";
    hob = apse.len;          // A_string_len    OUT (receiver kind)
    return hob;
  endfunction

  // ---- CONTROL: the receiver is a PACKAGE-level array, so its own element
  // never binds and the law is never reached.  Both producers leave BOTH
  // elements bare here, in the clone AND in the home.
  function automatic int pkgarr182_fn();
    int hob;
    hob = bard182_pkgfixed.size;   // A_pkgarr_size   OUT (base unbound)
    return hob;
  endfunction

endpackage

package bard182_imp;
  import bard182_home::*;
  int bard182_anchor;
endpackage

module bard182_top;
  initial bard182_imp::bard182_anchor = 0;
endmodule
