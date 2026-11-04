// § providerBodyCopyBind478 (two providers)
package u;
  class C; endclass
  function automatic void f();
    process p;
    C c;
    p = process::self();
    c = null;
  endfunction
endpackage
package a;
  import u::*;
  class A; function void g(); f(); endfunction endclass
endpackage
package b;
  import u::*;
  class B; function void g(); f(); endfunction endclass
endpackage
package t;
  import a::*; import b::*;
  class T; A h; B j; endclass
endpackage
module top; import t::*; T o; endmodule
