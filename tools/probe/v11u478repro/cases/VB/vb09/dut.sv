// § providerBodyCopyBind478 (a task with a local and a loop variable)
package u;
  class C; endclass
  function automatic void f();
    int r;
    for (int i = 0; i < 2; i++) r += i;
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
