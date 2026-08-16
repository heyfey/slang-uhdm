// r10uvm75 arm b1 — OUT-OF-BODY class method: the POSITIVE arm.
// Cells: a_arg   the WRITTEN iterator argument of an array method's `with`
//        b_bare  a BARE READ of that same iterator inside the with-expression
//        h_elem  a hier_path ELEMENT naming the iterator (must stay unbound)
package p75a;
  class ci75;
    int req;
  endclass
  class c75;
    ci75 q[$];
    int  iq[$];
    extern function int oobf(int k);
  endclass
  // OUT-OF-BODY definition: compiled in p75a's scope, where `item`/`node`
  // resolve to nothing.
  function int c75::oobf(int k);
    ci75 r[$];
    int  ri[$];
    r  = q.find(item) with (item.req == k);      // a_arg(item) + h_elem(item.req)
    ri = iq.find_index(node) with (node == k);   // a_arg(node) + b_bare(node)
    return r.size() + ri.size();
  endfunction
endpackage
import p75a::*;
module top75a;
  c75 c;
  int r;
  initial begin
    c = new();
    r = c.oobf(1);
  end
endmodule
