// r10uvm75 verifier arm — Scoreboard's shape: the package is COMPILED but no
// module IMPORTS it, so nothing hoists the class body and golden nets nothing.
// This is the over-fire control for the law's module half.
package p75e;
  class ci75;
    int req;
  endclass
  class c75;
    ci75 q[$];
    int  iq[$];
    extern function int oobf(int k);
  endclass
  function int c75::oobf(int k);
    ci75 r[$];
    int  ri[$];
    r  = q.find(item) with (item.req == k);
    ri = iq.find_index(node) with (node == k);
    return r.size() + ri.size();
  endfunction
endpackage
module top75e;                 // NO import of p75e
  int r;
  initial r = 0;
endmodule
