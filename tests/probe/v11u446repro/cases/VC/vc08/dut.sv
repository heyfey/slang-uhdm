// § clsBodyCallBindsHomeTopTf446
package p;
  function int rep(int v);
    return v + 1;
  endfunction
endpackage
package q;
  import p::*;
  class B;
    function int f(int a);
      return rep(a);
    endfunction
  endclass
endpackage
package r;
  import p::*;
  import q::*;
  class E extends B;
    function int g(int a);
      return rep(a) + f(a);
    endfunction
  endclass
endpackage
module top;
  import r::*;
  E e;
endmodule
