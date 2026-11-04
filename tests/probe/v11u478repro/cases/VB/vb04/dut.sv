// § providerBodyCopyBind478 (locals with initializers)
package u;
  class C; endclass
  function automatic void f();
    C c = null;
    int k = 3;
    if (c == null) k = 4;
  endfunction
endpackage
package a;
  import u::*;
  class A;
    function void g();
      f();
    endfunction
  endclass
endpackage
package t0;
  import a::*;
  class T0; A h; endclass
endpackage
module top; import t0::*; T0 o; endmodule
