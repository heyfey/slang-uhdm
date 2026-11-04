// § withCallParenSyntax286 — control: parenthesized randomize-with and plain array methods
package p;
  class c;
    rand int a;
    int q[$];
    function int f();
      int r;
      r = (this.randomize() with { a > 0; });
      r = (q.size()) + (q.sum());
      return r;
    endfunction
  endclass
endpackage
module top; import p::*; endmodule
