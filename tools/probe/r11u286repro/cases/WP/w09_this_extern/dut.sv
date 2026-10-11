// § withCallParenSyntax286 — this. receivers, an extern method defined out of body, a parameterized class
package p;
  class c #(int N = 2);
    int q[$];
    extern function int f();
    function int g();
      return 1 + (this.q.sum() with ( item * N ));
    endfunction
  endclass
  function int c::f();
    return 2 + (q.sum() with ( item ));
  endfunction
  typedef c#(3) c3;
endpackage
module top; import p::*; endmodule
