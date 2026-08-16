// r10uvm75 arm b3 — SHARING: one wire per NAME per module, minted at the
// FIRST reference and reused by every later function.  Two OOB methods reuse
// `item`; the second also introduces `node` LATER than `item`.
package p75c;
  class ci75;
    int req;
  endclass
  class c75;
    ci75 q[$];
    int  iq[$];
    extern function int f1(int k);
    extern function int f2(int k);
  endclass
  function int c75::f1(int k);
    ci75 r[$];
    r = q.find(item) with (item.req == k);      // FIRST `item` -> mint site
    return r.size();
  endfunction
  function int c75::f2(int k);
    ci75 r[$];
    int  ri[$];
    r  = q.find(item) with (item.req == k);     // SECOND `item` -> shares
    ri = iq.find_index(node) with (node == k);  // FIRST `node` -> mint site
    return r.size() + ri.size();
  endfunction
endpackage
import p75c::*;
module top75c;
  c75 c;
  int r;
  initial begin
    c = new();
    r = c.f1(1) + c.f2(2);
  end
endmodule
