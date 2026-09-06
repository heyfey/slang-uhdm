// r10v175 verifier arm G2 — a ONE-COMPONENT subscripted receiver, with and
// WITHOUT the clause, on the same array, to isolate what moves the span.
package amber_pier;
  class latch;
    int nest[$][$];
    int caught[$];
    int total;
    function new(); endfunction
    function void weigh(int slot, int rung);
      // h_with:    one component, with clause
      total  = nest[slot].sum() with (item);
      // h_nowith:  one component, SAME method, NO clause
      total  = nest[slot].sum();
      // h_size:    one component, size()
      total  = nest[slot].size();
      // h_find:    one component, find_index with clause
      caught = nest[slot].find_index() with (item > rung);
      // h_findnw:  one component, find_index NO clause
      caught = nest[slot].find_index();
      // h_push:    one component, a void method in statement position
      nest[slot].push_back(rung);
    endfunction
  endclass
endpackage
