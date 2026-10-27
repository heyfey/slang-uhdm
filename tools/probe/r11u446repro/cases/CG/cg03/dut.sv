// § cloneBodyCallBindsHomeTopTf446
package p;
  function int rep(int v);
    return v + 1;
  endfunction
  function int wrap(int v);
    return rep(v);
  endfunction
  class C;
    extern function int f(int a);
  endclass
  function int C::f(int a);
    return rep(a);
  endfunction
endpackage
package q;
  import p::*;
  class D;
    function int g(int b);
      return wrap(b);
    endfunction
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
