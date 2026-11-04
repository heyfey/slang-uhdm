// § providerBodyCopyBind478
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
  class A;
    function void g();
      f();
    endfunction
  endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
module top; import t::*; T o; endmodule
