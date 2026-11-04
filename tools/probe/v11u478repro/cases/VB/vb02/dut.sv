// § providerBodyCopyBind478 (two locals of one name in two blocks)
package u;
  class C; endclass
  function automatic void f();
    begin : b1
      int k;
      k = 1;
    end
    begin : b2
      int k;
      k = 2;
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
