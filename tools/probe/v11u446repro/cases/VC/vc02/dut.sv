// § clsBodyCallBindsHomeTopTf446
package p;
  function int rep(int v);
    return v + 1;
  endfunction
  function int oth(int v);
    return v + 2;
  endfunction
endpackage
package q;
  import p::*;
  function int rep(int v);
    return v + 5;
  endfunction
  class C;
    function int f(int a);
      return rep(a) + oth(a);
    endfunction
  endclass
endpackage
module top;
  import q::*;
  C c;
endmodule
