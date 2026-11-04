// § pkgFnCloneIdxNamesByChain296
package h;
  class c;
    int m;
    int arr[4];
    function int rub(input int x); return x + m; endfunction
  endclass
  parameter int HP = 1;
  int pv;
  task automatic t(input int a, output int r);
    c fl[4];
    int k;
    k = a;
    fl[0] = new();
    r = fl[k].rub(a);
  endtask
  function automatic int f(input int a);
    c fl[4];
    int k;
    k = a;
    fl[0] = new();
    return fl[k+1].rub(a);
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
