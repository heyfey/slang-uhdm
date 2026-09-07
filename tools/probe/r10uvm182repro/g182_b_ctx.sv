// r10uvm182 arm B — THE CONTEXT GRID.  The SAME parens-less built-in read
// (`<queue>.size` / `<queue>.max`) in six syntactic positions inside one
// wildcard-import clone body.
//
// UHDM's `hier_path::DeepClone` is context-FREE — it walks `Path_elems` and
// nothing else — so golden must mint the `func_call` in every position, and a
// law that only reaches one position (because OUR emitter builds a different
// element shape there) shows up here as a split cell rather than as silence.
package flint182_home;

  function automatic int ctx182_fn(int drum);
    int   sluice [$];
    int   ridge  [$];
    int   hob;
    int   tally  [8];
    // B_rhs        — plain assignment right-hand side
    hob = sluice.size;
    // B_cond       — an `if` condition
    if (sluice.size > 2) hob = hob + 1;
    // B_arg        — an argument of a call
    hob = ctx182_help(sluice.size);
    // B_index      — inside another expression's INDEX
    hob = tally[sluice.size];
    // B_binop      — one operand of a binary operation
    hob = sluice.size + drum;
    // B_forcond    — a for-loop condition, re-evaluated each pass
    for (int spoke = 0; spoke < sluice.size; spoke++) hob = hob + spoke;
    // B_ret        — the return expression itself
    ridge = sluice.max;
    return hob + ridge.size;
  endfunction

  function automatic int ctx182_help(int knap);
    return knap + 1;
  endfunction

endpackage

package flint182_imp;
  import flint182_home::*;
  int flint182_anchor;
endpackage

module flint182_top;
  initial flint182_imp::flint182_anchor = 0;
endmodule
