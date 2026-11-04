// § providerBodyCopyBind478 (a local declared after a statement in a nested begin and named like a formal-less outer local)
package u;
  class C; endclass
  function automatic void f();
    int k;
    k = 0;
    begin
      int k;
      k = 5;
    end
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
