// § clsBodyCallBindsHomeTopTf446
package p;
  function int rep(int v = 3);
    return v + 1;
  endfunction
endpackage
package q;
  import p::*;
  class C;
    int x = rep(1);
    function int f();
      return rep();
    endfunction
    static function int s();
      return rep(4);
    endfunction
  endclass
endpackage
module top;
  import q::*;
  C c;
endmodule
