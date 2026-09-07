// r10v182 arm I — THE CHAIN.  `<queue>.max.size` puts a MINTED func_call in
// the `previous` slot for the next element: `DeepClone` sets
// `previous = (any*)call`, and the next round's `any_cast<ref_obj*>(previous)`
// then FAILS, so golden must leave the third element bare.  The patch reads
// the same predecessor as `ref_obj(max)` whose Actual_group is now a
// `func_call`, which `arrayActual182` rejects — but then `bind9` runs on the
// third element, and a body local named `size` sits right there to be bound.
package rung182_home;
  function automatic int i_chain182_fn();
    int sluice [$];
    int size;
    int hob;
    size = 2;
    hob = sluice.max.size;              // I_chain
    hob = hob + size;
    return hob;
  endfunction
endpackage
package rung182_imp;
  import rung182_home::*;
  int rung182_anchor;
endpackage
module rung182_top;
  initial rung182_imp::rung182_anchor = 0;
endmodule
