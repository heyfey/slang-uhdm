// r10v175 verifier arm G — a ONE-COMPONENT subscripted receiver: the whole
// receiver path is a single indexed name and the hier_path has TWO elements.
package amber_dock;
  class latch;
    int nest[$][$];
    int fixmat[4][8];
    int assoc[string][$];
    int dyn2[][];
    int caught[$];
    int total;
    function new(); endfunction
    function void weigh(int slot, int rung);
      // g_qq: a queue of queues, one written component
      total = nest[slot].sum() with (item);
      // g_fix: a fixed 2-D unpacked array, one written component
      total = fixmat[slot].sum() with (item);
      // g_assoc: an associative array of queues, string key
      total = assoc["keel"].sum() with (item);
      // g_dyn: a dynamic array of dynamic arrays
      total = dyn2[slot].sum() with (item);
      // g_two: two written dimensions, one component
      total = nest[slot][rung];
      // g_find: the locator tail on a one-component receiver
      caught = nest[slot].find_index() with (item > rung);
      // g_nowith: the same receiver, NO clause (control)
      total = nest[slot].size();
    endfunction
  endclass
endpackage
