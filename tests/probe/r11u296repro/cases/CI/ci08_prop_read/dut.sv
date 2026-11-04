// § pkgFnCloneIdxNamesByChain296
package h;
  class c;
    int m;
    function int rub(input int x); return x + m; endfunction
  endclass
  typedef struct packed { logic [7:0] fld; } s_t;
  int pv;
  function automatic int f(input int a);
    c fl[4];
    int k;
    k = a;
    fl[0] = new();
    return fl[k].m;
  endfunction
endpackage
package j;
  import h::*;
  function automatic int warp(input int z);
    return f(0);
  endfunction
endpackage
module dut(output int o);
  import j::*;
  initial o = warp(1);
endmodule
