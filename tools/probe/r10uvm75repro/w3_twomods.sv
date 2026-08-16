// VERIFIER arm w3 — TWO modules hoist the same package.  bindHoistedClassPropRefs
// writes cpr.ref->Actual_group(bind9) unconditionally, so the LAST module
// processed wins the singular vpiActual for a ref shared by both.  Pre-existing
// machinery, but this pass is the first to route iterator refs through it.
// EMPTY PRODUCT CELL in the grid.
package p75w3;
  class ci75;
    int req;
  endclass
  class c75;
    ci75 q[$];
    extern function int oobf(int k);
  endclass
  function int c75::oobf(int k);
    ci75 r[$];
    r = q.find(item) with (item.req == k);
    return r.size();
  endfunction
endpackage
import p75w3::*;
module sub75w3;
  c75 c;
  int r;
  initial begin c = new(); r = c.oobf(2); end
endmodule
module top75w3;
  c75 c;
  int r;
  sub75w3 u_sub();
  initial begin c = new(); r = c.oobf(1); end
endmodule
