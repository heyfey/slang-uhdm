// r10uvm75 arm b2 — the NEGATIVE arm: byte-for-byte b1 with the method
// written IN BODY.  Same names, same with-clauses, same importing module.
// If golden nets these too, the OOB gate is wrong.
package p75b;
  class ci75;
    int req;
  endclass
  class c75;
    ci75 q[$];
    int  iq[$];
    // IN-BODY definition: compiled at CLASS scope.
    function int inbf(int k);
      ci75 r[$];
      int  ri[$];
      r  = q.find(item) with (item.req == k);
      ri = iq.find_index(node) with (node == k);
      return r.size() + ri.size();
    endfunction
  endclass
endpackage
import p75b::*;
module top75b;
  c75 c;
  int r;
  initial begin
    c = new();
    r = c.inbf(1);
  end
endmodule
