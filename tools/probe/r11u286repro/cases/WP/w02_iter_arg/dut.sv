// § withCallParenSyntax286 — parenthesized with-call with a written iterator argument
package p;
  class c;
    int q[$];
    function int f();
      int r;
      r = 2 * (q.sum(x) with ( x + 1 ));
      r = 1 + (q.sum(z) with (z));
      return r;
    endfunction
  endclass
endpackage
module top; import p::*; endmodule
