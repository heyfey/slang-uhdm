// § oobClsRetCallSharesCalleeRet457
package p;
  function int rep(int v);
    return v + 1;
  endfunction
  class C;
    function int f(int a);
      return rep(a);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  C c;
endmodule
