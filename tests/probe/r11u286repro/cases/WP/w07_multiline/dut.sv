// § withCallParenSyntax286 — parenthesized with-call split over two lines
package p;
  class c;
    int q[$];
    function int f();
      int r;
      r = 1 + (q.sum() with
                 ( item * 2 ));
      return r;
    endfunction
  endclass
endpackage
module top; import p::*; endmodule
