// § providerBodyCopyBind478 (two provider levels: t2 through t through a)
package u;
  function automatic int f(int x);
    int y;
    int z;
    y = x + 1;
    z = y;
    return z;
  endfunction
endpackage
package a;
  import u::*;
  class A; function int g(); return f(1); endfunction endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
package t2;
  import t::*;
  class T2; T h; endclass
endpackage
module top; import t2::*; T2 o; endmodule
