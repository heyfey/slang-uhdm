// § providerBodyCopyBind478 (a local in a nested begin)
package u;
  function automatic int f(int x);
    int y;
    y = x;
    begin
      int w;
      w = y + 1;
      y = w;
    end
    return y;
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
