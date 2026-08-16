// r10uvm75 arm b4 — the KIND trap.  slang gives a FOREACH loop variable the
// same SymbolKind::Iterator as a `with`-clause iterator.  Both live in ONE
// out-of-body method here, so a rule written on the KIND nets `fv` too.
package p75d;
  class ci75;
    int req;
  endclass
  class c75;
    ci75 q[$];
    int  iq[$];
    extern function int f3(int k);
  endclass
  function int c75::f3(int k);
    ci75 r[$];
    int  s;
    r = q.find(item) with (item.req == k);   // with-iterator: NET
    foreach (iq[fv])                         // foreach loop var: NOT a net
      s = s + iq[fv];
    return r.size() + s;
  endfunction
endpackage
import p75d::*;
module top75d;
  c75 c;
  int r;
  initial begin
    c = new();
    r = c.f3(1);
  end
endmodule
