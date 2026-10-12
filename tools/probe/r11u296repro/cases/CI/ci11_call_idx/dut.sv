// § pkgFnCloneIdxNamesByChain296
package h;
  class c;
    int m;
    function int rub(input int x); return x + m; endfunction
  endclass
  typedef struct packed { logic [7:0] fld; } s_t;
  int pv;
  function automatic int g(input int x); return x; endfunction
  function automatic int f(input int a);
    c fl[$];
    c one;
    one = new();
    fl.push_back(one);
    return a + fl[g(0)].rub(1);
  endfunction
endpackage
package j;
  import h::*;
  function automatic int warp(input int z);
    return f(z);
  endfunction
endpackage
module dut(output int o);
  import j::*;
  initial o = warp(1);
endmodule
