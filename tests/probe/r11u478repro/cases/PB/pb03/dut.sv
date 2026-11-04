// § providerBodyCopyBind478 (int locals read and written)
package u;
  function automatic int f(int x);
    int y;
    int z;
    y = x + 1;
    z = y * 2;
    return z;
  endfunction
endpackage
package a;
  import u::*;
  class A;
    function int g(); return f(1); endfunction
  endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
module top; import t::*; T o; endmodule
