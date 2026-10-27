// § clsBodyCallBindsHomeTopTf446
package p;
  function int rep(int v);
    int k;
    k = v + 1;
    return k;
  endfunction
endpackage
package q;
  import p::*;
  class C;
    function int f(int a);
      return rep(a);
    endfunction
  endclass
  function int g(int b);
    return rep(b);
  endfunction
endpackage
module top;
  import q::*;
  C c;
  initial $display(g(1));
endmodule
