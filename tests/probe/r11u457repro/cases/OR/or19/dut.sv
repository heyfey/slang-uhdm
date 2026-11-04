// § oobClsRetCallSharesCalleeRet457
package p;
  function int rep(int v);
    return v + 1;
  endfunction
  class C;
    extern static function int f(int a);
  endclass
  function int C::f(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  initial $display(C::f(3));
endmodule
