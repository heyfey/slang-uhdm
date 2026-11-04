// § providerBodyCopyBind478 (a local in a fork)
package u;
  class C; endclass
  function automatic void f();
    int r;
    fork
      begin
        int k;
        k = 2;
        r = k;
      end
    join_none
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
