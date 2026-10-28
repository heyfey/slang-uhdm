// § oobClsRetCallSharesCalleeRet457
package p;
  function int rep(); return $urandom; endfunction
  class C;
    extern function int f(int a);
  endclass
  function int C::f(int a);
    return rep();
  endfunction
endpackage
module top;
  import p::*;
  C c;
endmodule
