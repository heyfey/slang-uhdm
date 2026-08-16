// VERIFIER arm w1 — the hoisting module ALREADY DECLARES a signal named `item`.
// This pass newly injects iterator NAMES into the classPropRefs binding pool,
// and `item`/`node` are among the most common identifiers in real RTL.  If
// golden does NOT bind the iterator ref to a same-named DECLARED module net,
// this patch silently rewires a real signal.  EMPTY PRODUCT CELL in the grid.
package p75w1;
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
import p75w1::*;
module top75w1;
  logic item;          // <-- DECLARED, same name as the iterator
  logic [3:0] node;    // <-- DECLARED, same name, and VECTORED
  c75 c;
  int r;
  initial begin
    c = new();
    item = 1'b0;
    r = c.oobf(1);
  end
endmodule
