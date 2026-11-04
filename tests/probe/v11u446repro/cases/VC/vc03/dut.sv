// § clsBodyCallBindsHomeTopTf446
package p1;
  function int f1(int v);
    return v + 1;
  endfunction
endpackage
package p2;
  function int f2(int v);
    return v + 2;
  endfunction
endpackage
package q;
  import p1::*;
  import p2::*;
  class C;
    function int f(int a);
      return f1(a) + f2(a);
    endfunction
  endclass
endpackage
module top;
  import q::*;
  C c;
endmodule
