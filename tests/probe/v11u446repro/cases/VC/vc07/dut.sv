// § cloneBodyCallBindsHomeTopTf446
package p;
  function int rep(int v);
    return v + 1;
  endfunction
  class K;
    extern function int m(int a);
  endclass
  function int K::m(int a);
    return rep(a);
  endfunction
endpackage
package q;
  import p::*;
  class D;
    K k;
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
