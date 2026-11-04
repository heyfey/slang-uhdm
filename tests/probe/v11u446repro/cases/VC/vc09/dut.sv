// § clsBodyCallBindsHomeTopTf446
package p;
  function int rep(int v);
    return v + 1;
  endfunction
endpackage
package q;
  import p::*;
  class C;
    function int f(int a);
      return p::rep(a) + rep(a);
    endfunction
  endclass
endpackage
module top;
  import q::*;
  C c;
endmodule
