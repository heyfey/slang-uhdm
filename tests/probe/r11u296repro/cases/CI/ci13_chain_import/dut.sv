// § pkgFnCloneIdxNamesByChain296
package h;
  class c;
    int m;
    function int rub(input int x); return x + m; endfunction
  endclass
  typedef struct packed { logic [7:0] fld; } s_t;
  int pv;
  function automatic int f(input int a);
    c fl[$];
    c one;
    int k;
    one = new();
    fl.push_back(one);
    k = 0;
    return a + fl[k].rub(k);
  endfunction
endpackage
package j;
  import h::*;
  function automatic int warp(input int z);
    return f(z);
  endfunction
endpackage
package k2;
  import j::*;
  function automatic int hop(); return warp(2); endfunction
endpackage
module dut(output int o);
  import k2::*;
  initial o = hop();
endmodule
