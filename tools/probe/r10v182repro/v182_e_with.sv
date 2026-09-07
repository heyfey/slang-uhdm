// r10v182 arm E — THE `with`-CLAUSE FACE.  This is the arm that hunts the
// OVER-FIRE the implementer's R1 predicts but does not test: `max`/`min` accept
// a parens-less `with` clause exactly as `unique`/`and`/`or`/`xor` do, and R1
// says Surelog's grammar turns a parens-less built-in call into a
// `method_func_call` element where our emitter builds a plain `ref_obj`.  If
// `q.max with (...)` lands in that class, golden mints NOTHING and the patch
// mints a `func_call` -> OVER-FIRE on legal SV.
package weld182_home;

  function automatic int e_with182_fn();
    int  sluice [$];
    int  bay    [$];
    int  hob;
    sluice.push_back(4);
    bay = sluice.max;                    // E_max_bare      (the known cell)
    bay = sluice.max with (item + 1);    // E_max_with
    bay = sluice.min with (item - 1);    // E_min_with
    bay = sluice.unique with (item);     // E_unique_with   (negative name)
    hob = sluice.sum with (item);        // E_sum_with      (negative name)
    hob = sluice.and;                    // E_and_bare      (negative name)
    hob = sluice.or;                     // E_or_bare       (negative name)
    hob = sluice.xor;                    // E_xor_bare      (negative name)
    bay = sluice.unique;                 // E_unique_bare   (negative name)
    bay = sluice.find with (item > 2);   // E_find_with     (IN name, no parens)
    hob = hob + bay.size;
    return hob;
  endfunction

endpackage

package weld182_imp;
  import weld182_home::*;
  int weld182_anchor;
endpackage

module weld182_top;
  initial weld182_imp::weld182_anchor = 0;
endmodule
