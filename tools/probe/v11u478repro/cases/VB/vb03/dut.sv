// § providerBodyCopyBind478 (a three-level chain)
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
package t0;
  import a::*;
  class T0; A h; endclass
endpackage
package t1;
  import t0::*;
  class T1; T0 h; endclass
endpackage
module top; import t1::*; T1 o; endmodule
