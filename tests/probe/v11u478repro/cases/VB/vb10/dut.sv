// § providerBodyCopyBind478 (a class method out of body as the provided subroutine)
package u;
  class C;
    extern function int m();
  endclass
  function int C::m();
    process p;
    int k;
    p = process::self();
    k = 1;
    return k;
  endfunction
endpackage
package a;
  import u::*;
  class A; C c; endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
module top; import t::*; T o; endmodule
