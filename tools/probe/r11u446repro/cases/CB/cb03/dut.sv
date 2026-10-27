// § clsBodyCallBindsHomeTopTf446
package p;
  function int rep(int v);
    return v + 1;
  endfunction
endpackage
package q;
  import p::*;
  class B;
    function int rep(int v);
      return v - 1;
    endfunction
  endclass
  class C extends B;
    function int f(int a);
      return rep(a);
    endfunction
  endclass
endpackage
module top;
  import q::*;
  C c;
endmodule
