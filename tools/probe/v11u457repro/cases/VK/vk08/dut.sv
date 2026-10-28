// § pkgRetCallSharesConstRet457
package p;
  function int rep(); return 5; endfunction
  class C;
    function int f(int a);
      return rep();
    endfunction
    extern function int g(int a);
  endclass
  function int C::g(int a);
    return rep();
  endfunction
endpackage
module top;
  import p::*;
  C c;
endmodule
