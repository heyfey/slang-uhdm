// § providerBodyCopyBind478 (a static local)
package u;
  class C; endclass
  function automatic void f();
    static int cnt;
    int k;
    cnt++;
    k = cnt;
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
