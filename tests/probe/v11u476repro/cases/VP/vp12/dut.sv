// § cloneViaProviderTopClone476
package u;
  class K;
    int v;
    extern function int m(int x);
  endclass
  function int K::m(int x);
    int y;
    y = x + v;
    return y;
  endfunction
  function automatic int f(int x);
    K k;
    k = new;
    return k.m(x);
  endfunction
endpackage
package a;
  import u::*;
  class AC;
    function int g();
      return f(1);
    endfunction
  endclass
endpackage
package t;
  import a::*;
  class TC; AC h; endclass
endpackage
module top; import t::*; TC o; endmodule
