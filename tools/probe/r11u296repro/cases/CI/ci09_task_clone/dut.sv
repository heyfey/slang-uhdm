// § pkgFnCloneIdxNamesByChain296
package h;
  class c;
    int m;
    function int rub(input int x); return x + m; endfunction
  endclass
  typedef struct packed { logic [7:0] fld; } s_t;
  int pv;
  task automatic t(input int a, output int r);
    c fl[$];
    c one;
    int k;
    one = new();
    fl.push_back(one);
    k = 0;
    r = fl[k].rub(a);
  endtask
  function automatic int f(input int a);
    int r;
    r = a;
    return r;
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
