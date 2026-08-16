// VERIFIER arm w2 — the IMPLICIT iterator: no argument is written in the
// parens at all, so SITE A never fires and SITE B is the FIRST reference of
// the name.  The implementer's b1/b3/b4 all write the argument; corpus cell 4
// (`find with (item == i)` @859:52) only ever bound a wire ANOTHER cell had
// already minted.  Does golden MINT at the with-expression's span?
// EMPTY PRODUCT CELL in the grid.
package p75w2;
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
    r  = q.find() with (item.req == k);     // implicit `item`, FIRST reference
    ri = iq.find_index() with (item == k);  // implicit `item` again, int queue
    return r.size() + ri.size();
  endfunction
endpackage
import p75w2::*;
module top75w2;
  c75 c;
  int r;
  initial begin
    c = new();
    r = c.oobf(1);
  end
endmodule
