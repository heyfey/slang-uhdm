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
    int ix[2];
    int k;
    one = new();
    fl.push_back(one);
    k = 0;
    ix[0] = 0;
    return a + fl[ix[k]].rub(2);
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
