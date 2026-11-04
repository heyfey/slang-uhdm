// § clsBodyCallBindsHomeTopTf446
package p;
  function int rep(int v);
    return v + 1;
  endfunction
endpackage
package q;
  import p::*;
  function int g(int b);
    return rep(b);
  endfunction
  class C;
    class N;
      function int h(int a);
        return rep(a);
      endfunction
    endclass
    function int f(int a);
      return g(a) + rep(a);
    endfunction
  endclass
endpackage
module top;
  import q::*;
  C c;
endmodule
