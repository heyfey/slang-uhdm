// § withCallParenSyntax286 — find / product / max with-calls in parentheses
package p;
  class c;
    int q[$];
    int s[$];
    function void f();
      int r;
      s = (q.find(e) with ( e > 2 ));
      r = 4 - (q.product() with ( item ));
      s = (q.max() with ( item ));
    endfunction
  endclass
endpackage
module top; import p::*; endmodule
